//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestorePurchasesRequest {
  /// Returns a new [RestorePurchasesRequest] instance.
  RestorePurchasesRequest({
    this.platform = const RestorePurchasesRequestPlatformEnum._('auto'),
    required this.idempotencyKey,
    required this.deviceAnonId,
    this.appleReceipt,
    this.googlePurchases = const [],
    this.googlePurchaseToken,
    this.productId,
    this.packageName,
  });

  RestorePurchasesRequestPlatformEnum platform;

  String idempotencyKey;

  String deviceAnonId;

  /// Latest Apple App Store receipt (base64)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? appleReceipt;

  /// List of Google purchases to restore (Batch mode)
  List<GooglePurchaseItem> googlePurchases;

  /// DEPRECATED: Use google_purchases
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? googlePurchaseToken;

  /// DEPRECATED: Use google_purchases
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? productId;

  /// DEPRECATED: Use google_purchases
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? packageName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestorePurchasesRequest &&
    other.platform == platform &&
    other.idempotencyKey == idempotencyKey &&
    other.deviceAnonId == deviceAnonId &&
    other.appleReceipt == appleReceipt &&
    _deepEquality.equals(other.googlePurchases, googlePurchases) &&
    other.googlePurchaseToken == googlePurchaseToken &&
    other.productId == productId &&
    other.packageName == packageName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (platform.hashCode) +
    (idempotencyKey.hashCode) +
    (deviceAnonId.hashCode) +
    (appleReceipt == null ? 0 : appleReceipt!.hashCode) +
    (googlePurchases.hashCode) +
    (googlePurchaseToken == null ? 0 : googlePurchaseToken!.hashCode) +
    (productId == null ? 0 : productId!.hashCode) +
    (packageName == null ? 0 : packageName!.hashCode);

  @override
  String toString() => 'RestorePurchasesRequest[platform=$platform, idempotencyKey=$idempotencyKey, deviceAnonId=$deviceAnonId, appleReceipt=$appleReceipt, googlePurchases=$googlePurchases, googlePurchaseToken=$googlePurchaseToken, productId=$productId, packageName=$packageName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'platform'] = this.platform;
      json[r'idempotency_key'] = this.idempotencyKey;
      json[r'device_anon_id'] = this.deviceAnonId;
    if (this.appleReceipt != null) {
      json[r'apple_receipt'] = this.appleReceipt;
    } else {
      json[r'apple_receipt'] = null;
    }
      json[r'google_purchases'] = this.googlePurchases;
    if (this.googlePurchaseToken != null) {
      json[r'google_purchase_token'] = this.googlePurchaseToken;
    } else {
      json[r'google_purchase_token'] = null;
    }
    if (this.productId != null) {
      json[r'product_id'] = this.productId;
    } else {
      json[r'product_id'] = null;
    }
    if (this.packageName != null) {
      json[r'package_name'] = this.packageName;
    } else {
      json[r'package_name'] = null;
    }
    return json;
  }

  /// Returns a new [RestorePurchasesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestorePurchasesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestorePurchasesRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestorePurchasesRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestorePurchasesRequest(
        platform: RestorePurchasesRequestPlatformEnum.fromJson(json[r'platform']) ?? RestorePurchasesRequestPlatformEnum.auto_,
        idempotencyKey: mapValueOfType<String>(json, r'idempotency_key')!,
        deviceAnonId: mapValueOfType<String>(json, r'device_anon_id')!,
        appleReceipt: mapValueOfType<String>(json, r'apple_receipt'),
        googlePurchases: GooglePurchaseItem.listFromJson(json[r'google_purchases']),
        googlePurchaseToken: mapValueOfType<String>(json, r'google_purchase_token'),
        productId: mapValueOfType<String>(json, r'product_id'),
        packageName: mapValueOfType<String>(json, r'package_name'),
      );
    }
    return null;
  }

  static List<RestorePurchasesRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestorePurchasesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestorePurchasesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestorePurchasesRequest> mapFromJson(dynamic json) {
    final map = <String, RestorePurchasesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestorePurchasesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestorePurchasesRequest-objects as value to a dart map
  static Map<String, List<RestorePurchasesRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestorePurchasesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestorePurchasesRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'idempotency_key',
    'device_anon_id',
  };
}


class RestorePurchasesRequestPlatformEnum {
  /// Instantiate a new enum with the provided [value].
  const RestorePurchasesRequestPlatformEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const apple = RestorePurchasesRequestPlatformEnum._(r'apple');
  static const google = RestorePurchasesRequestPlatformEnum._(r'google');
  static const auto = RestorePurchasesRequestPlatformEnum._(r'auto');

  /// List of all possible values in this [enum][RestorePurchasesRequestPlatformEnum].
  static const values = <RestorePurchasesRequestPlatformEnum>[
    apple,
    google,
    auto,
  ];

  static RestorePurchasesRequestPlatformEnum? fromJson(dynamic value) => RestorePurchasesRequestPlatformEnumTypeTransformer().decode(value);

  static List<RestorePurchasesRequestPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestorePurchasesRequestPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestorePurchasesRequestPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RestorePurchasesRequestPlatformEnum] to String,
/// and [decode] dynamic data back to [RestorePurchasesRequestPlatformEnum].
class RestorePurchasesRequestPlatformEnumTypeTransformer {
  factory RestorePurchasesRequestPlatformEnumTypeTransformer() => _instance ??= const RestorePurchasesRequestPlatformEnumTypeTransformer._();

  const RestorePurchasesRequestPlatformEnumTypeTransformer._();

  String encode(RestorePurchasesRequestPlatformEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RestorePurchasesRequestPlatformEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RestorePurchasesRequestPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'apple': return RestorePurchasesRequestPlatformEnum.apple;
        case r'google': return RestorePurchasesRequestPlatformEnum.google;
        case r'auto': return RestorePurchasesRequestPlatformEnum.auto;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RestorePurchasesRequestPlatformEnumTypeTransformer] instance.
  static RestorePurchasesRequestPlatformEnumTypeTransformer? _instance;
}


