//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VerifyGooglePurchaseRequest {
  /// Returns a new [VerifyGooglePurchaseRequest] instance.
  VerifyGooglePurchaseRequest({
    required this.packageName,
    required this.productId,
    required this.purchaseToken,
    required this.idempotencyKey,
    this.deviceAnonId,
  });

  String packageName;

  String productId;

  String purchaseToken;

  String idempotencyKey;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deviceAnonId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VerifyGooglePurchaseRequest &&
    other.packageName == packageName &&
    other.productId == productId &&
    other.purchaseToken == purchaseToken &&
    other.idempotencyKey == idempotencyKey &&
    other.deviceAnonId == deviceAnonId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (packageName.hashCode) +
    (productId.hashCode) +
    (purchaseToken.hashCode) +
    (idempotencyKey.hashCode) +
    (deviceAnonId == null ? 0 : deviceAnonId!.hashCode);

  @override
  String toString() => 'VerifyGooglePurchaseRequest[packageName=$packageName, productId=$productId, purchaseToken=$purchaseToken, idempotencyKey=$idempotencyKey, deviceAnonId=$deviceAnonId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'package_name'] = this.packageName;
      json[r'product_id'] = this.productId;
      json[r'purchase_token'] = this.purchaseToken;
      json[r'idempotency_key'] = this.idempotencyKey;
    if (this.deviceAnonId != null) {
      json[r'device_anon_id'] = this.deviceAnonId;
    } else {
      json[r'device_anon_id'] = null;
    }
    return json;
  }

  /// Returns a new [VerifyGooglePurchaseRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VerifyGooglePurchaseRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VerifyGooglePurchaseRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VerifyGooglePurchaseRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VerifyGooglePurchaseRequest(
        packageName: mapValueOfType<String>(json, r'package_name')!,
        productId: mapValueOfType<String>(json, r'product_id')!,
        purchaseToken: mapValueOfType<String>(json, r'purchase_token')!,
        idempotencyKey: mapValueOfType<String>(json, r'idempotency_key')!,
        deviceAnonId: mapValueOfType<String>(json, r'device_anon_id'),
      );
    }
    return null;
  }

  static List<VerifyGooglePurchaseRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VerifyGooglePurchaseRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VerifyGooglePurchaseRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VerifyGooglePurchaseRequest> mapFromJson(dynamic json) {
    final map = <String, VerifyGooglePurchaseRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VerifyGooglePurchaseRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VerifyGooglePurchaseRequest-objects as value to a dart map
  static Map<String, List<VerifyGooglePurchaseRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VerifyGooglePurchaseRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VerifyGooglePurchaseRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'package_name',
    'product_id',
    'purchase_token',
    'idempotency_key',
  };
}

