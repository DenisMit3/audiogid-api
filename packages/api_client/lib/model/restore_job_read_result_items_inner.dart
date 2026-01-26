//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestoreJobReadResultItemsInner {
  /// Returns a new [RestoreJobReadResultItemsInner] instance.
  RestoreJobReadResultItemsInner({
    this.productId,
    this.status,
    this.error,
    this.orderId,
    this.tokenHash,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? productId;

  RestoreJobReadResultItemsInnerStatusEnum? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? error;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? orderId;

  /// SHA256 prefix of token for debug
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tokenHash;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestoreJobReadResultItemsInner &&
    other.productId == productId &&
    other.status == status &&
    other.error == error &&
    other.orderId == orderId &&
    other.tokenHash == tokenHash;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (productId == null ? 0 : productId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (orderId == null ? 0 : orderId!.hashCode) +
    (tokenHash == null ? 0 : tokenHash!.hashCode);

  @override
  String toString() => 'RestoreJobReadResultItemsInner[productId=$productId, status=$status, error=$error, orderId=$orderId, tokenHash=$tokenHash]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.productId != null) {
      json[r'product_id'] = this.productId;
    } else {
      json[r'product_id'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    if (this.orderId != null) {
      json[r'order_id'] = this.orderId;
    } else {
      json[r'order_id'] = null;
    }
    if (this.tokenHash != null) {
      json[r'token_hash'] = this.tokenHash;
    } else {
      json[r'token_hash'] = null;
    }
    return json;
  }

  /// Returns a new [RestoreJobReadResultItemsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestoreJobReadResultItemsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestoreJobReadResultItemsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestoreJobReadResultItemsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestoreJobReadResultItemsInner(
        productId: mapValueOfType<String>(json, r'product_id'),
        status: RestoreJobReadResultItemsInnerStatusEnum.fromJson(json[r'status']),
        error: mapValueOfType<String>(json, r'error'),
        orderId: mapValueOfType<String>(json, r'order_id'),
        tokenHash: mapValueOfType<String>(json, r'token_hash'),
      );
    }
    return null;
  }

  static List<RestoreJobReadResultItemsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreJobReadResultItemsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreJobReadResultItemsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestoreJobReadResultItemsInner> mapFromJson(dynamic json) {
    final map = <String, RestoreJobReadResultItemsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestoreJobReadResultItemsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestoreJobReadResultItemsInner-objects as value to a dart map
  static Map<String, List<RestoreJobReadResultItemsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestoreJobReadResultItemsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestoreJobReadResultItemsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class RestoreJobReadResultItemsInnerStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const RestoreJobReadResultItemsInnerStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const restored = RestoreJobReadResultItemsInnerStatusEnum._(r'restored');
  static const existing = RestoreJobReadResultItemsInnerStatusEnum._(r'existing');
  static const failed = RestoreJobReadResultItemsInnerStatusEnum._(r'failed');

  /// List of all possible values in this [enum][RestoreJobReadResultItemsInnerStatusEnum].
  static const values = <RestoreJobReadResultItemsInnerStatusEnum>[
    restored,
    existing,
    failed,
  ];

  static RestoreJobReadResultItemsInnerStatusEnum? fromJson(dynamic value) => RestoreJobReadResultItemsInnerStatusEnumTypeTransformer().decode(value);

  static List<RestoreJobReadResultItemsInnerStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreJobReadResultItemsInnerStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreJobReadResultItemsInnerStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RestoreJobReadResultItemsInnerStatusEnum] to String,
/// and [decode] dynamic data back to [RestoreJobReadResultItemsInnerStatusEnum].
class RestoreJobReadResultItemsInnerStatusEnumTypeTransformer {
  factory RestoreJobReadResultItemsInnerStatusEnumTypeTransformer() => _instance ??= const RestoreJobReadResultItemsInnerStatusEnumTypeTransformer._();

  const RestoreJobReadResultItemsInnerStatusEnumTypeTransformer._();

  String encode(RestoreJobReadResultItemsInnerStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RestoreJobReadResultItemsInnerStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RestoreJobReadResultItemsInnerStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'restored': return RestoreJobReadResultItemsInnerStatusEnum.restored;
        case r'existing': return RestoreJobReadResultItemsInnerStatusEnum.existing;
        case r'failed': return RestoreJobReadResultItemsInnerStatusEnum.failed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RestoreJobReadResultItemsInnerStatusEnumTypeTransformer] instance.
  static RestoreJobReadResultItemsInnerStatusEnumTypeTransformer? _instance;
}


