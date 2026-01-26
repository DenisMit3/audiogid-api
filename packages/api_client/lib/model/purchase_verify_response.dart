//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseVerifyResponse {
  /// Returns a new [PurchaseVerifyResponse] instance.
  PurchaseVerifyResponse({
    required this.verified,
    required this.granted,
    this.entitlementGrantId,
    this.orderId,
    required this.traceId,
    this.error,
  });

  bool verified;

  bool granted;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? entitlementGrantId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? orderId;

  String traceId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? error;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseVerifyResponse &&
    other.verified == verified &&
    other.granted == granted &&
    other.entitlementGrantId == entitlementGrantId &&
    other.orderId == orderId &&
    other.traceId == traceId &&
    other.error == error;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (verified.hashCode) +
    (granted.hashCode) +
    (entitlementGrantId == null ? 0 : entitlementGrantId!.hashCode) +
    (orderId == null ? 0 : orderId!.hashCode) +
    (traceId.hashCode) +
    (error == null ? 0 : error!.hashCode);

  @override
  String toString() => 'PurchaseVerifyResponse[verified=$verified, granted=$granted, entitlementGrantId=$entitlementGrantId, orderId=$orderId, traceId=$traceId, error=$error]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'verified'] = this.verified;
      json[r'granted'] = this.granted;
    if (this.entitlementGrantId != null) {
      json[r'entitlement_grant_id'] = this.entitlementGrantId;
    } else {
      json[r'entitlement_grant_id'] = null;
    }
    if (this.orderId != null) {
      json[r'order_id'] = this.orderId;
    } else {
      json[r'order_id'] = null;
    }
      json[r'trace_id'] = this.traceId;
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    return json;
  }

  /// Returns a new [PurchaseVerifyResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseVerifyResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PurchaseVerifyResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PurchaseVerifyResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PurchaseVerifyResponse(
        verified: mapValueOfType<bool>(json, r'verified')!,
        granted: mapValueOfType<bool>(json, r'granted')!,
        entitlementGrantId: mapValueOfType<String>(json, r'entitlement_grant_id'),
        orderId: mapValueOfType<String>(json, r'order_id'),
        traceId: mapValueOfType<String>(json, r'trace_id')!,
        error: mapValueOfType<String>(json, r'error'),
      );
    }
    return null;
  }

  static List<PurchaseVerifyResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseVerifyResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseVerifyResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseVerifyResponse> mapFromJson(dynamic json) {
    final map = <String, PurchaseVerifyResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseVerifyResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseVerifyResponse-objects as value to a dart map
  static Map<String, List<PurchaseVerifyResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseVerifyResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseVerifyResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'verified',
    'granted',
    'trace_id',
  };
}

