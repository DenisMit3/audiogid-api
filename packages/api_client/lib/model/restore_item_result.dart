//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestoreItemResult {
  /// Returns a new [RestoreItemResult] instance.
  RestoreItemResult({
    this.productId,
    this.status,
    this.errorCode,
    this.orderId,
    this.sourceRefHashPrefix,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? productId;

  RestoreItemResultStatusEnum? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? errorCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? orderId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sourceRefHashPrefix;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestoreItemResult &&
    other.productId == productId &&
    other.status == status &&
    other.errorCode == errorCode &&
    other.orderId == orderId &&
    other.sourceRefHashPrefix == sourceRefHashPrefix;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (productId == null ? 0 : productId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (errorCode == null ? 0 : errorCode!.hashCode) +
    (orderId == null ? 0 : orderId!.hashCode) +
    (sourceRefHashPrefix == null ? 0 : sourceRefHashPrefix!.hashCode);

  @override
  String toString() => 'RestoreItemResult[productId=$productId, status=$status, errorCode=$errorCode, orderId=$orderId, sourceRefHashPrefix=$sourceRefHashPrefix]';

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
    if (this.errorCode != null) {
      json[r'error_code'] = this.errorCode;
    } else {
      json[r'error_code'] = null;
    }
    if (this.orderId != null) {
      json[r'order_id'] = this.orderId;
    } else {
      json[r'order_id'] = null;
    }
    if (this.sourceRefHashPrefix != null) {
      json[r'source_ref_hash_prefix'] = this.sourceRefHashPrefix;
    } else {
      json[r'source_ref_hash_prefix'] = null;
    }
    return json;
  }

  /// Returns a new [RestoreItemResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestoreItemResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestoreItemResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestoreItemResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestoreItemResult(
        productId: mapValueOfType<String>(json, r'product_id'),
        status: RestoreItemResultStatusEnum.fromJson(json[r'status']),
        errorCode: mapValueOfType<String>(json, r'error_code'),
        orderId: mapValueOfType<String>(json, r'order_id'),
        sourceRefHashPrefix: mapValueOfType<String>(json, r'source_ref_hash_prefix'),
      );
    }
    return null;
  }

  static List<RestoreItemResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreItemResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreItemResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestoreItemResult> mapFromJson(dynamic json) {
    final map = <String, RestoreItemResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestoreItemResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestoreItemResult-objects as value to a dart map
  static Map<String, List<RestoreItemResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestoreItemResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestoreItemResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class RestoreItemResultStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const RestoreItemResultStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const created = RestoreItemResultStatusEnum._(r'created');
  static const existing = RestoreItemResultStatusEnum._(r'existing');
  static const failed = RestoreItemResultStatusEnum._(r'failed');

  /// List of all possible values in this [enum][RestoreItemResultStatusEnum].
  static const values = <RestoreItemResultStatusEnum>[
    created,
    existing,
    failed,
  ];

  static RestoreItemResultStatusEnum? fromJson(dynamic value) => RestoreItemResultStatusEnumTypeTransformer().decode(value);

  static List<RestoreItemResultStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreItemResultStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreItemResultStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RestoreItemResultStatusEnum] to String,
/// and [decode] dynamic data back to [RestoreItemResultStatusEnum].
class RestoreItemResultStatusEnumTypeTransformer {
  factory RestoreItemResultStatusEnumTypeTransformer() => _instance ??= const RestoreItemResultStatusEnumTypeTransformer._();

  const RestoreItemResultStatusEnumTypeTransformer._();

  String encode(RestoreItemResultStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RestoreItemResultStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RestoreItemResultStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'created': return RestoreItemResultStatusEnum.created;
        case r'existing': return RestoreItemResultStatusEnum.existing;
        case r'failed': return RestoreItemResultStatusEnum.failed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RestoreItemResultStatusEnumTypeTransformer] instance.
  static RestoreItemResultStatusEnumTypeTransformer? _instance;
}


