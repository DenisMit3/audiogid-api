import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'qr_mapping_repository.g.dart';

/// Resolved QR mapping result
class QrMappingResult {
  final String targetType;
  final String targetId;
  final String? redirectUrl;

  QrMappingResult({
    required this.targetType,
    required this.targetId,
    this.redirectUrl,
  });
}

/// Repository for resolving QR codes to POI/Tour IDs
/// Supports online API calls and offline cache fallback
class QrMappingRepository {
  final api.PublicApi _api;
  final AppDatabase _db;

  QrMappingRepository(this._api, this._db);


  /// Resolve a QR code to a target type and ID
  /// First tries API, then falls back to offline cache or local POI lookup
  Future<QrMappingResult?> resolveCode(String code) async {
    // 1. Try online API if connected
    try {
      final result = await _resolveFromApi(code);
      if (result != null) {
        await _cacheMapping(code, result);
        return result;
      }
    } catch (e) {
      debugPrint('QR API resolve failed: $e');
    }

    // 2. Try offline cache (previously resolved codes)
    final cached = await _resolveFromCache(code);
    if (cached != null) return cached;

    // 3. Try local POI lookup (if code is directly a POI ID)
    return _resolveFromPoiTable(code);
  }

  /// Resolve code from API: GET /public/qr/resolve?code=...
  Future<QrMappingResult?> _resolveFromApi(String code) async {
    try {
      final response = await _api.apiClient.invokeAPI(
        '/public/qr/resolve',
        'GET',
        [api.QueryParam('code', code)],
        null,
        {},
        {},
        null,
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = await _api.apiClient.deserializeAsync(
          response.body,
          'Map<String, dynamic>',
        ) as Map<String, dynamic>;

        return QrMappingResult(
          targetType: data['target_type'] as String,
          targetId: data['target_id'] as String,
          redirectUrl: data['redirect_url'] as String?,
        );
      }
    } catch (e) {
      // Ignored, will fall back
    }
    return null;
  }

  /// Resolve code from local cache
  Future<QrMappingResult?> _resolveFromCache(String code) async {
    try {
      final cached = await (_db.select(_db.qrMappingsCache)
            ..where((t) => t.code.equals(code)))
          .getSingleOrNull();

      if (cached != null) {
        return QrMappingResult(
          targetType: cached.targetType,
          targetId: cached.targetId,
          redirectUrl: cached.redirectUrl,
        );
      }
    } catch (e) {
      debugPrint('QR cache lookup error: $e');
    }
    return null;
  }

  /// Try to find a POI with this ID locally
  Future<QrMappingResult?> _resolveFromPoiTable(String code) async {
    try {
      // Check if code is a valid ID in Pois table
      final poi = await (_db.select(_db.pois)..where((t) => t.id.equals(code))).getSingleOrNull();
      if (poi != null) {
        return QrMappingResult(targetType: 'poi', targetId: poi.id);
      }
      
      // Also check if code might be 'osmId' or 'wikidataId' if you want robust lookup
      // For now, ID is primary.
    } catch (e) {
      debugPrint('QR local POI lookup error: $e');
    }
    return null;
  }

  /// Cache a resolved mapping for offline use
  Future<void> _cacheMapping(String code, QrMappingResult result) async {
    try {
      await _db.into(_db.qrMappingsCache).insertOnConflictUpdate(
            QrMappingsCacheCompanion(
              code: Value(code),
              targetType: Value(result.targetType),
              targetId: Value(result.targetId),
              redirectUrl: Value(result.redirectUrl),
              cachedAt: Value(DateTime.now()),
            ),
          );
    } catch (e) {
      debugPrint('QR cache insert error: $e');
    }
  }

  /// Sync all QR mappings for offline use
  /// Call this ahead of time (e.g., when downloading city data)
  Future<void> syncMappingsForCity(String citySlug) async {
    try {
      // Try to fetch all mappings for a city
      // This would require a new API endpoint like /public/qr?city=xxx
      // For now, we'll skip this as it may not exist
      debugPrint('QR mapping sync for city $citySlug - endpoint TBD');
    } catch (e) {
      debugPrint('QR sync error: $e');
    }
  }

  /// Clear old cached mappings
  Future<void> cleanupOldMappings({Duration maxAge = const Duration(days: 30)}) async {
    try {
      final cutoff = DateTime.now().subtract(maxAge);
      await (_db.delete(_db.qrMappingsCache)
            ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
          .go();
    } catch (e) {
      debugPrint('QR cache cleanup error: $e');
    }
  }
}

@riverpod
QrMappingRepository qrMappingRepository(Ref ref) {
  return QrMappingRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
  );
}
