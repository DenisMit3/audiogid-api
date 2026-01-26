/// Result of a purchase verification attempt.
class PurchaseResult {
  final bool verified;
  final bool granted;
  final String? entitlementGrantId;
  final String? orderId;
  final String? traceId;
  final String? error;

  PurchaseResult({
    required this.verified,
    required this.granted,
    this.entitlementGrantId,
    this.orderId,
    this.traceId,
    this.error,
  });

  factory PurchaseResult.fromApiModel(dynamic apiModel) {
    return PurchaseResult(
      verified: apiModel.verified ?? false,
      granted: apiModel.granted ?? false,
      entitlementGrantId: apiModel.entitlementGrantId,
      orderId: apiModel.orderId,
      traceId: apiModel.traceId,
      error: apiModel.error,
    );
  }

  factory PurchaseResult.failure(String error) => PurchaseResult(
    verified: false,
    granted: false,
    error: error,
  );

  bool get isSuccess => verified && granted;
}
