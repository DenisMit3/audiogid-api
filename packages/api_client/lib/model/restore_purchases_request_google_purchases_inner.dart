//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestorePurchasesRequestGooglePurchasesInner {
  /// Returns a new [RestorePurchasesRequestGooglePurchasesInner] instance.
  RestorePurchasesRequestGooglePurchasesInner({
    required this.packageName,
    required this.productId,
    required this.purchaseToken,
  });

  String packageName;

  String productId;

  String purchaseToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestorePurchasesRequestGooglePurchasesInner &&
    other.packageName == packageName &&
    other.productId == productId &&
    other.purchaseToken == purchaseToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (packageName.hashCode) +
    (productId.hashCode) +
    (purchaseToken.hashCode);

  @override
  String toString() => 'RestorePurchasesRequestGooglePurchasesInner[packageName=$packageName, productId=$productId, purchaseToken=$purchaseToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'package_name'] = this.packageName;
      json[r'product_id'] = this.productId;
      json[r'purchase_token'] = this.purchaseToken;
    return json;
  }

  /// Returns a new [RestorePurchasesRequestGooglePurchasesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestorePurchasesRequestGooglePurchasesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestorePurchasesRequestGooglePurchasesInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestorePurchasesRequestGooglePurchasesInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestorePurchasesRequestGooglePurchasesInner(
        packageName: mapValueOfType<String>(json, r'package_name')!,
        productId: mapValueOfType<String>(json, r'product_id')!,
        purchaseToken: mapValueOfType<String>(json, r'purchase_token')!,
      );
    }
    return null;
  }

  static List<RestorePurchasesRequestGooglePurchasesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestorePurchasesRequestGooglePurchasesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestorePurchasesRequestGooglePurchasesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestorePurchasesRequestGooglePurchasesInner> mapFromJson(dynamic json) {
    final map = <String, RestorePurchasesRequestGooglePurchasesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestorePurchasesRequestGooglePurchasesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestorePurchasesRequestGooglePurchasesInner-objects as value to a dart map
  static Map<String, List<RestorePurchasesRequestGooglePurchasesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestorePurchasesRequestGooglePurchasesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestorePurchasesRequestGooglePurchasesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'package_name',
    'product_id',
    'purchase_token',
  };
}

