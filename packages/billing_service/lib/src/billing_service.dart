import 'dart:convert';
import 'dart:io';

import 'package:api_client/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models/entitlement.dart';
import 'models/purchase_result.dart';

/// High-level billing service with server-side verification.
/// 
/// Usage:
/// ```dart
/// final service = BillingService(deviceAnonId: 'device-123');
/// await service.initialize();
/// 
/// // After native purchase completes:
/// final result = await service.verifyApplePurchase(receipt: '...', productId: 'city_access');
/// if (result.isSuccess) {
///   // User now has access
/// }
/// ```
class BillingService {
  final String deviceAnonId;
  final String? apiBasePath;
  
  late final BillingApi _billingApi;
  late final SharedPreferences _prefs;
  
  List<Entitlement> _cachedEntitlements = [];
  DateTime? _lastFetched;
  
  static const _cacheKey = 'billing_entitlements_cache';
  static const _cacheDuration = Duration(minutes: 5);
  
  BillingService({
    required this.deviceAnonId,
    this.apiBasePath,
  });

  /// Initialize the service. Must be called before other methods.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Configure API client
    final apiClient = ApiClient(basePath: apiBasePath ?? 'https://audiogid-api.vercel.app/v1');
    _billingApi = BillingApi(apiClient);
    
    // Load cached entitlements
    _loadCachedEntitlements();
  }

  void _loadCachedEntitlements() {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final List<dynamic> list = jsonDecode(cached);
        _cachedEntitlements = list.map((e) => Entitlement.fromJson(e)).toList();
      } catch (_) {
        _cachedEntitlements = [];
      }
    }
  }

  Future<void> _saveCachedEntitlements() async {
    final json = jsonEncode(_cachedEntitlements.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, json);
  }

  /// Fetch entitlements from server and update cache.
  Future<List<Entitlement>> fetchEntitlements({bool forceRefresh = false}) async {
    // Check cache validity
    if (!forceRefresh && _lastFetched != null) {
      if (DateTime.now().difference(_lastFetched!) < _cacheDuration) {
        return _cachedEntitlements;
      }
    }
    
    try {
      final apiEntitlements = await _billingApi.getEntitlements(deviceAnonId);
      if (apiEntitlements != null) {
        _cachedEntitlements = apiEntitlements
            .map((e) => Entitlement.fromApiModel(e))
            .toList();
        _lastFetched = DateTime.now();
        await _saveCachedEntitlements();
      }
    } catch (e) {
      // On network error, use cached data
      print('[BillingService] Fetch error, using cache: $e');
    }
    
    return _cachedEntitlements;
  }

  /// Get cached entitlements (no network call).
  List<Entitlement> get cachedEntitlements => _cachedEntitlements;

  /// Check if user has access to given content.
  bool hasAccess(String ref, {String scope = 'city'}) {
    return _cachedEntitlements.any((e) => e.grantsAccessTo(ref, scope));
  }

  /// Verify an Apple App Store receipt with the server.
  Future<PurchaseResult> verifyApplePurchase({
    required String receipt,
    required String productId,
  }) async {
    final idempotencyKey = const Uuid().v4();
    
    try {
      final request = VerifyAppleReceiptRequest(
        receipt: receipt,
        productId: productId,
        idempotencyKey: idempotencyKey,
        deviceAnonId: deviceAnonId,
      );
      
      final response = await _billingApi.verifyAppleReceipt(request);
      if (response == null) {
        return PurchaseResult.failure('Empty response');
      }
      
      final result = PurchaseResult.fromApiModel(response);
      
      // Refresh entitlements if purchase succeeded
      if (result.isSuccess) {
        await fetchEntitlements(forceRefresh: true);
      }
      
      return result;
    } catch (e) {
      return PurchaseResult.failure('Network error: $e');
    }
  }

  /// Verify a Google Play purchase with the server.
  Future<PurchaseResult> verifyGooglePurchase({
    required String purchaseToken,
    required String productId,
    String? packageName,
  }) async {
    final idempotencyKey = const Uuid().v4();
    final package = packageName ?? _detectPackageName();
    
    try {
      final request = VerifyGooglePurchaseRequest(
        packageName: package,
        productId: productId,
        purchaseToken: purchaseToken,
        idempotencyKey: idempotencyKey,
        deviceAnonId: deviceAnonId,
      );
      
      final response = await _billingApi.verifyGooglePurchase(request);
      if (response == null) {
        return PurchaseResult.failure('Empty response');
      }
      
      final result = PurchaseResult.fromApiModel(response);
      
      if (result.isSuccess) {
        await fetchEntitlements(forceRefresh: true);
      }
      
      return result;
    } catch (e) {
      return PurchaseResult.failure('Network error: $e');
    }
  }

  String _detectPackageName() {
    // Default package name for Audiogid
    return 'app.audiogid.kaliningrad';
  }

  /// Clear local cache (for logout/account deletion).
  Future<void> clearCache() async {
    _cachedEntitlements = [];
    _lastFetched = null;
    await _prefs.remove(_cacheKey);
  }
}
