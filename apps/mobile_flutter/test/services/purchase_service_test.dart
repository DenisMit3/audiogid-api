import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_flutter/data/services/purchase_service.dart';
import 'package:api_client/api.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/domain/repositories/entitlement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

// Mocks
class MockBillingApi extends Mock implements BillingApi {}
class MockInAppPurchase extends Mock implements InAppPurchase {}
class MockEntitlementRepository extends Mock implements EntitlementRepository {}
class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late ProviderContainer container;
  late MockBillingApi mockBillingApi;
  late MockInAppPurchase mockInAppPurchase;
  late MockEntitlementRepository mockEntitlementRepository;
  late StreamController<List<PurchaseDetails>> purchaseStreamController;

  setUp(() {
    SharedPreferences.setMockInitialValues({'device_anon_id': 'test_device_id'});
    
    mockBillingApi = MockBillingApi();
    mockInAppPurchase = MockInAppPurchase();
    mockEntitlementRepository = MockEntitlementRepository();
    purchaseStreamController = StreamController<List<PurchaseDetails>>.broadcast();

    when(() => mockInAppPurchase.purchaseStream)
        .thenAnswer((_) => purchaseStreamController.stream);
    when(() => mockInAppPurchase.isAvailable())
        .thenAnswer((_) async => true);

    registerFallbackValue(VerifyAppleReceiptRequest((b) => b..idempotencyKey = 'test'));
    registerFallbackValue(VerifyGooglePurchaseRequest((b) => b..idempotencyKey = 'test'));

    container = ProviderContainer(
      overrides: [
        billingApiProvider.overrideWithValue(mockBillingApi),
        inAppPurchaseProvider.overrideWithValue(mockInAppPurchase),
        entitlementRepositoryProvider.overrideWithValue(mockEntitlementRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    purchaseStreamController.close();
  });

  group('PurchaseService', () {
    test('initial state should be initial', () {
      final service = container.read(purchaseServiceProvider);
      expect(service.status, PurchaseStatusState.initial);
    });

    // Note: Since we can't easily set Platform.isIOS to true/false in tests without
    // using a specific platform override or digging deep into flutter_test,
    // we assume the default platform (likely android or linux in this environment).
    // However, the service checks Platform.isIOS/isAndroid.
    // Logic: verification calls specific API based on platform.
    
    test('should verify purchase on stream update', () async {
      // Arrange
      final service = container.read(purchaseServiceProvider.notifier);
      // Wait for init
      await Future.delayed(Duration.zero);
      
      final verificationData = PurchaseVerificationData(
        localVerificationData: 'local',
        serverVerificationData: 'server_token',
        source: 'app_store',
      );
      
      final purchaseDetails = PurchaseDetails(
        purchaseID: 'purchase_id',
        productID: 'product_id',
        verificationData: verificationData,
        transactionDate: '1234567890',
        status: PurchaseStatus.purchased,
      );

      // Mock verify response
      // We'll mock both Google and Apple to cover whichever platform the test runs on
      final verifyResponse = PurchaseVerifyResponse((b) => b
        ..verified = true
        ..granted = true
      );
      
      when(() => mockBillingApi.verifyGooglePurchase(
            verifyGooglePurchaseRequest: any(named: 'verifyGooglePurchaseRequest')))
          .thenAnswer((_) async => Response<PurchaseVerifyResponse>(
            requestOptions: RequestOptions(path: ''),
            data: verifyResponse,
            statusCode: 200,
          ));
          
       when(() => mockBillingApi.verifyAppleReceipt(
            verifyAppleReceiptRequest: any(named: 'verifyAppleReceiptRequest')))
          .thenAnswer((_) async => Response<PurchaseVerifyResponse>(
            requestOptions: RequestOptions(path: ''),
            data: verifyResponse,
            statusCode: 200,
          ));
          
      when(() => mockEntitlementRepository.syncGrants()).thenAnswer((_) async => {});

      // Act
      purchaseStreamController.add([purchaseDetails]);
      
      // Assert
      // We need to wait for the async processing in the listener
      await Future.delayed(const Duration(milliseconds: 100));
      
      final newState = container.read(purchaseServiceProvider);
      expect(newState.status, PurchaseStatusState.success);
      verify(() => mockEntitlementRepository.syncGrants()).called(1);
    });

    test('should handle verification failure', () async {
      final service = container.read(purchaseServiceProvider.notifier);
      await Future.delayed(Duration.zero);
      
      final purchaseDetails = PurchaseDetails(
        purchaseID: 'purchase_id',
        productID: 'product_id',
        verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: ''),
        transactionDate: '1234567890',
        status: PurchaseStatus.purchased,
      );

       final verifyResponse = PurchaseVerifyResponse((b) => b
        ..verified = false
        ..granted = false
        ..error = 'Verification failed'
      );

      when(() => mockBillingApi.verifyGooglePurchase(
            verifyGooglePurchaseRequest: any(named: 'verifyGooglePurchaseRequest')))
          .thenAnswer((_) async => Response<PurchaseVerifyResponse>(
             requestOptions: RequestOptions(path: ''),
            data: verifyResponse,
          ));

      // Act
      purchaseStreamController.add([purchaseDetails]);
      await Future.delayed(const Duration(milliseconds: 100));

      final newState = container.read(purchaseServiceProvider);
      expect(newState.status, PurchaseStatusState.error);
      expect(newState.error, 'Verification failed');
    });
    test('should execute parallel purchases in buyBatch', () async {
      final service = container.read(purchaseServiceProvider.notifier);
      await Future.delayed(Duration.zero);
      
      // Arrange
      final productDetails = ProductDetails(
        id: 'product_1',
        title: 'Product 1',
        description: 'Desc',
        price: '1.00',
        rawPrice: 1.0,
        currencyCode: 'USD',
      );
      
      // Mock Billing API to return product details for batch
      when(() => mockBillingApi.batchPurchase(batchPurchaseReq: any(named: 'batchPurchaseReq')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: BatchPurchaseRes((b) => b..productIds.replace(['product_1']))
          ));
          
      // Mock IAP queryProductDetails
      when(() => mockInAppPurchase.queryProductDetails(any()))
          .thenAnswer((_) async => ProductDetailsResponse(
              productDetails: [productDetails],
              notFoundIDs: [],
          ));

      // Mock IAP buyNonConsumable
      when(() => mockInAppPurchase.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')))
          .thenAnswer((_) async => true);

      // Act
      await service.buyBatch(['poi_1'], []); // Call
      
      // Assert
      verify(() => mockBillingApi.batchPurchase(batchPurchaseReq: any(named: 'batchPurchaseReq'))).called(1);
      verify(() => mockInAppPurchase.queryProductDetails(any())).called(1);
      // Wait for async call inside map/Future.wait if needed, but buyBatch awaits Future.wait so it should be done.
      verify(() => mockInAppPurchase.buyNonConsumable(purchaseParam: any(named: 'purchaseParam'))).called(1);
    });
  });
}
