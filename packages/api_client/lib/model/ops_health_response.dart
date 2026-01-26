//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OpsHealthResponse {
  /// Returns a new [OpsHealthResponse] instance.
  OpsHealthResponse({
    this.status,
    this.checks = const [],
    this.error,
  });

  OpsHealthResponseStatusEnum? status;

  List<String> checks;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? error;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpsHealthResponse &&
    other.status == status &&
    _deepEquality.equals(other.checks, checks) &&
    other.error == error;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status == null ? 0 : status!.hashCode) +
    (checks.hashCode) +
    (error == null ? 0 : error!.hashCode);

  @override
  String toString() => 'OpsHealthResponse[status=$status, checks=$checks, error=$error]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
      json[r'checks'] = this.checks;
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    return json;
  }

  /// Returns a new [OpsHealthResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OpsHealthResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OpsHealthResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OpsHealthResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OpsHealthResponse(
        status: OpsHealthResponseStatusEnum.fromJson(json[r'status']),
        checks: json[r'checks'] is Iterable
            ? (json[r'checks'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        error: mapValueOfType<String>(json, r'error'),
      );
    }
    return null;
  }

  static List<OpsHealthResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpsHealthResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpsHealthResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OpsHealthResponse> mapFromJson(dynamic json) {
    final map = <String, OpsHealthResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OpsHealthResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OpsHealthResponse-objects as value to a dart map
  static Map<String, List<OpsHealthResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OpsHealthResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OpsHealthResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class OpsHealthResponseStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const OpsHealthResponseStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const ok = OpsHealthResponseStatusEnum._(r'ok');
  static const fail = OpsHealthResponseStatusEnum._(r'fail');

  /// List of all possible values in this [enum][OpsHealthResponseStatusEnum].
  static const values = <OpsHealthResponseStatusEnum>[
    ok,
    fail,
  ];

  static OpsHealthResponseStatusEnum? fromJson(dynamic value) => OpsHealthResponseStatusEnumTypeTransformer().decode(value);

  static List<OpsHealthResponseStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpsHealthResponseStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpsHealthResponseStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OpsHealthResponseStatusEnum] to String,
/// and [decode] dynamic data back to [OpsHealthResponseStatusEnum].
class OpsHealthResponseStatusEnumTypeTransformer {
  factory OpsHealthResponseStatusEnumTypeTransformer() => _instance ??= const OpsHealthResponseStatusEnumTypeTransformer._();

  const OpsHealthResponseStatusEnumTypeTransformer._();

  String encode(OpsHealthResponseStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a OpsHealthResponseStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OpsHealthResponseStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'ok': return OpsHealthResponseStatusEnum.ok;
        case r'fail': return OpsHealthResponseStatusEnum.fail;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [OpsHealthResponseStatusEnumTypeTransformer] instance.
  static OpsHealthResponseStatusEnumTypeTransformer? _instance;
}


