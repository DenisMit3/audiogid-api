//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BatchPurchaseResponse {
  /// Returns a new [BatchPurchaseResponse] instance.
  BatchPurchaseResponse({
    this.productIds = const [],
    this.alreadyOwned = const [],
  });

  List<String> productIds;
  List<String> alreadyOwned;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BatchPurchaseResponse &&
    _deepEquality.equals(other.productIds, productIds) &&
    _deepEquality.equals(other.alreadyOwned, alreadyOwned);

  @override
  int get hashCode =>
    (productIds.hashCode) +
    (alreadyOwned.hashCode);

  @override
  String toString() => 'BatchPurchaseResponse[productIds=$productIds, alreadyOwned=$alreadyOwned]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'product_ids'] = this.productIds;
    json[r'already_owned'] = this.alreadyOwned;
    return json;
  }

  /// Returns a new [BatchPurchaseResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  static BatchPurchaseResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();
      return BatchPurchaseResponse(
        productIds: json[r'product_ids'] is List ? (json[r'product_ids'] as List).cast<String>() : const [],
        alreadyOwned: json[r'already_owned'] is List ? (json[r'already_owned'] as List).cast<String>() : const [],
      );
    }
    return null;
  }
}
