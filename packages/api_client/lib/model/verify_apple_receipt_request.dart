//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VerifyAppleReceiptRequest {
  /// Returns a new [VerifyAppleReceiptRequest] instance.
  VerifyAppleReceiptRequest({
    required this.receipt,
    required this.productId,
    required this.idempotencyKey,
    this.deviceAnonId,
  });

  /// Base64 receipt or JWS transaction
  String receipt;

  String productId;

  String idempotencyKey;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deviceAnonId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VerifyAppleReceiptRequest &&
    other.receipt == receipt &&
    other.productId == productId &&
    other.idempotencyKey == idempotencyKey &&
    other.deviceAnonId == deviceAnonId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (receipt.hashCode) +
    (productId.hashCode) +
    (idempotencyKey.hashCode) +
    (deviceAnonId == null ? 0 : deviceAnonId!.hashCode);

  @override
  String toString() => 'VerifyAppleReceiptRequest[receipt=$receipt, productId=$productId, idempotencyKey=$idempotencyKey, deviceAnonId=$deviceAnonId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'receipt'] = this.receipt;
      json[r'product_id'] = this.productId;
      json[r'idempotency_key'] = this.idempotencyKey;
    if (this.deviceAnonId != null) {
      json[r'device_anon_id'] = this.deviceAnonId;
    } else {
      json[r'device_anon_id'] = null;
    }
    return json;
  }

  /// Returns a new [VerifyAppleReceiptRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VerifyAppleReceiptRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VerifyAppleReceiptRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VerifyAppleReceiptRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VerifyAppleReceiptRequest(
        receipt: mapValueOfType<String>(json, r'receipt')!,
        productId: mapValueOfType<String>(json, r'product_id')!,
        idempotencyKey: mapValueOfType<String>(json, r'idempotency_key')!,
        deviceAnonId: mapValueOfType<String>(json, r'device_anon_id'),
      );
    }
    return null;
  }

  static List<VerifyAppleReceiptRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VerifyAppleReceiptRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VerifyAppleReceiptRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VerifyAppleReceiptRequest> mapFromJson(dynamic json) {
    final map = <String, VerifyAppleReceiptRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VerifyAppleReceiptRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VerifyAppleReceiptRequest-objects as value to a dart map
  static Map<String, List<VerifyAppleReceiptRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VerifyAppleReceiptRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VerifyAppleReceiptRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'receipt',
    'product_id',
    'idempotency_key',
  };
}

