import 'dart:async';
import 'dart:io';

import 'package:api_client/api.dart' as api;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/data/repositories/entitlement_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'purchase_service.g.dart';

enum PurchaseStatusState { initial, pending, success, error, restored }

class PurchaseState {
  final PurchaseStatusState status;
  final String? error;

  PurchaseState({this.status = PurchaseStatusState.initial, this.error});
}

@riverpod
InAppPurchase inAppPurchase(Ref ref) {
  return InAppPurchase.instance;
}

@riverpod
class PurchaseService extends _$PurchaseService {
  late final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Keep track of pending restore job
  final _restorePollInterval = const Duration(seconds: 2);

  @override
  PurchaseState build() {
    _iap = ref.watch(inAppPurchaseProvider);
    _initIap();
    
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return PurchaseState();
  }

  Future<void> _initIap() async {
    final available = await _iap.isAvailable();
    if (!available) {
      state = PurchaseState(status: PurchaseStatusState.error, error: "Store not available");
      return;
    }
    
    if (Platform.isIOS) {
      final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatform.setDelegate(PaymentQueueDelegate());
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
         state = PurchaseState(status: PurchaseStatusState.error, error: error.toString());
      },
    );
  }
  
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    final restored = purchaseDetailsList.where((p) => p.status == PurchaseStatus.restored).toList();
    final others = purchaseDetailsList.where((p) => p.status != PurchaseStatus.restored).toList();

    for (var purchaseDetails in others) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        state = PurchaseState(status: PurchaseStatusState.pending);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          state = PurchaseState(status: PurchaseStatusState.error, error: purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          final verified = await _verifyPurchase(purchaseDetails);
          if (verified) {
             state = PurchaseState(status: PurchaseStatusState.success);
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }

    if (restored.isNotEmpty) {
      bool allSuccess = true;
      for (var purchaseDetails in restored) {
        final verified = await _verifyPurchase(purchaseDetails);
         if (!verified) {
           allSuccess = false;
         }
         
         if (purchaseDetails.pendingCompletePurchase) {
           await _iap.completePurchase(purchaseDetails);
         }
      }
      
      if (allSuccess) {
         state = PurchaseState(status: PurchaseStatusState.restored);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final billingApi = ref.read(billingApiProvider);
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_anon_id') ?? '';

    final verificationData = purchaseDetails.verificationData;
    
    try {
        bool verified = false;
        bool granted = false;
        String? errorMsg;

        if (Platform.isIOS) {
            final response = await billingApi.verifyAppleReceipt(
                api.VerifyAppleReceiptRequest(
                  receipt: verificationData.serverVerificationData,
                  productId: purchaseDetails.productID,
                  idempotencyKey: const Uuid().v4(),
                  deviceAnonId: deviceId,
                )
            );
            if (response != null) {
              verified = response.verified ?? false;
              granted = response.granted ?? false;
              errorMsg = response.error;
            }
        } else if (Platform.isAndroid) {
             final packageInfo = await PackageInfo.fromPlatform();
             final response = await billingApi.verifyGooglePurchase(
                 api.VerifyGooglePurchaseRequest(
                    packageName: packageInfo.packageName,
                    productId: purchaseDetails.productID,
                    purchaseToken: verificationData.serverVerificationData,
                    idempotencyKey: const Uuid().v4(),
                    deviceAnonId: deviceId,
                 )
             );
             if (response != null) {
              verified = response.verified ?? false;
              granted = response.granted ?? false;
              errorMsg = response.error;
            }
        }
        
        if (verified == true && granted == true) {
             await ref.read(entitlementRepositoryProvider).syncGrants();
             
             // Log analytics
             ref.read(analyticsServiceProvider).logEvent('purchase_completed', {
               'product_id': purchaseDetails.productID,
               'price': purchaseDetails.transactionDate,
               'currency': 'RUB',
             });
             
             return true;
        } else {
             state = PurchaseState(status: PurchaseStatusState.error, error: errorMsg ?? "Verification failed");
             return false;
        }
    } catch (e) {
        if (kDebugMode) {
          print("Verification error: $e");
        }
        state = PurchaseState(status: PurchaseStatusState.error, error: e.toString());
        return false;
    }
  }
  
  Future<void> buy(ProductDetails product) async {
      state = PurchaseState(status: PurchaseStatusState.pending);
      final purchaseParam = PurchaseParam(productDetails: product);
      try {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } catch (e) {
        state = PurchaseState(status: PurchaseStatusState.error, error: "Buy failed: $e");
      }
  }

  Future<void> buyBatch(List<String> poiIds, List<String> tourIds) async {
      state = PurchaseState(status: PurchaseStatusState.pending);
      try {
         final billingApi = ref.read(billingApiProvider);
         final prefs = await SharedPreferences.getInstance();
         final deviceId = prefs.getString('device_anon_id') ?? '';
         
         final res = await billingApi.batchPurchase(
            api.BatchPurchaseRequest(
               poiIds: poiIds,
               tourIds: tourIds,
               deviceAnonId: deviceId,
            )
         );
         
         if (res == null) throw Exception("Empty response");

         final products = res.productIds?.toList() ?? [];
         
         if (products.isEmpty) {
             await ref.read(entitlementRepositoryProvider).syncGrants();
             state = PurchaseState(status: PurchaseStatusState.restored); 
             return;
         }
         
         final productDetails = await fetchProducts(products.toSet());
         if (productDetails.isEmpty) {
             state = PurchaseState(status: PurchaseStatusState.error, error: "Products not found in store");
             return;
         }
         
         // Parallel execution for better UX
         await Future.wait(productDetails.map((p) async {
             final purchaseParam = PurchaseParam(productDetails: p);
             await _iap.buyNonConsumable(purchaseParam: purchaseParam);
         }));
         
      } catch (e) {
         state = PurchaseState(status: PurchaseStatusState.error, error: "Batch buy failed: $e");
      }
  }
  
  Future<List<ProductDetails>> fetchProducts(Set<String> kIds) async {
      final response = await _iap.queryProductDetails(kIds);
      if (response.error != null) {
        throw Exception(response.error!.message);
      }
      return response.productDetails;
  }
  
  /// Restore purchases using server-side async polling if possible,
  /// otherwise falls back to local restore stream.
  Future<void> restorePurchases() async {
      state = PurchaseState(status: PurchaseStatusState.pending);
      
      try {
        // Platform specific handling for server-side restore
        if (Platform.isIOS) {
             await _iap.restorePurchases();
        } else if (Platform.isAndroid) {
             final androidPlatform = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
             final response = await androidPlatform.queryPastPurchases();
             
             if (response.pastPurchases.isNotEmpty) {
               await _startServerRestoreAndroid(response.pastPurchases);
             } else {
               state = PurchaseState(status: PurchaseStatusState.restored);
             }
        } else {
             state = PurchaseState(status: PurchaseStatusState.error, error: "Platform not supported");
        }
      } catch (e) {
          state = PurchaseState(status: PurchaseStatusState.error, error: "Restore failed: $e");
      }
  }

  Future<void> _startServerRestoreAndroid(List<GooglePlayPurchaseDetails> purchases) async {
      final billingApi = ref.read(billingApiProvider);
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_anon_id') ?? '';
      final packageInfo = await PackageInfo.fromPlatform();

      // Convert to GooglePurchaseItem
      final googleItems = purchases.map((p) => api.GooglePurchaseItem(
         packageName: packageInfo.packageName,
         productId: p.productID,
         purchaseToken: p.verificationData.serverVerificationData,
      )).toList();

      try {
        final result = await billingApi.restorePurchases(
           api.RestorePurchasesRequest(
              platform: api.RestorePurchasesRequestPlatformEnum.google,
              idempotencyKey: const Uuid().v4(),
              deviceAnonId: deviceId,
              googlePurchases: googleItems,
           )
        );
        
        if (result != null) {
           await _pollRestoreJob(result.jobId ?? '');
        }
      } catch (e) {
         state = PurchaseState(status: PurchaseStatusState.error, error: "Server restore failed, check internet");
      }
  }
  
  Future<void> _pollRestoreJob(String jobId) async {
      if (jobId.isEmpty) {
        state = PurchaseState(status: PurchaseStatusState.error, error: "No job ID returned");
        return;
      }
      
      final billingApi = ref.read(billingApiProvider);
      int attempts = 0;
      
      while (attempts < 30) {
         attempts++;
         await Future.delayed(_restorePollInterval);
         try {
           final status = await billingApi.getRestoreJobStatus(jobId);
           if (status?.status == api.RestoreJobReadStatusEnum.COMPLETED) {
              await ref.read(entitlementRepositoryProvider).syncGrants();
              state = PurchaseState(status: PurchaseStatusState.restored);
              break;
           } else if (status?.status == api.RestoreJobReadStatusEnum.FAILED) {
              state = PurchaseState(status: PurchaseStatusState.error, error: status?.lastError ?? "Restore Job Failed");
              break;
           }
         } catch (e) {
             state = PurchaseState(status: PurchaseStatusState.error, error: "Polling failed");
             break;
         }
      }
      if (attempts >= 30) {
         state = PurchaseState(status: PurchaseStatusState.error, error: "Restore timed out");
      }
  }
}

class PaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }
  
  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
