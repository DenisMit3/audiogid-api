//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestoreJobRead {
  /// Returns a new [RestoreJobRead] instance.
  RestoreJobRead({
    this.id,
    this.status,
    this.result,
    this.lastError,
    this.traceId,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  RestoreJobReadStatusEnum? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  RestoreJobReadResult? result;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastError;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? traceId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestoreJobRead &&
    other.id == id &&
    other.status == status &&
    other.result == result &&
    other.lastError == lastError &&
    other.traceId == traceId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (result == null ? 0 : result!.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (traceId == null ? 0 : traceId!.hashCode);

  @override
  String toString() => 'RestoreJobRead[id=$id, status=$status, result=$result, lastError=$lastError, traceId=$traceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.result != null) {
      json[r'result'] = this.result;
    } else {
      json[r'result'] = null;
    }
    if (this.lastError != null) {
      json[r'last_error'] = this.lastError;
    } else {
      json[r'last_error'] = null;
    }
    if (this.traceId != null) {
      json[r'trace_id'] = this.traceId;
    } else {
      json[r'trace_id'] = null;
    }
    return json;
  }

  /// Returns a new [RestoreJobRead] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestoreJobRead? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestoreJobRead[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestoreJobRead[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestoreJobRead(
        id: mapValueOfType<String>(json, r'id'),
        status: RestoreJobReadStatusEnum.fromJson(json[r'status']),
        result: RestoreJobReadResult.fromJson(json[r'result']),
        lastError: mapValueOfType<String>(json, r'last_error'),
        traceId: mapValueOfType<String>(json, r'trace_id'),
      );
    }
    return null;
  }

  static List<RestoreJobRead> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreJobRead>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreJobRead.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestoreJobRead> mapFromJson(dynamic json) {
    final map = <String, RestoreJobRead>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestoreJobRead.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestoreJobRead-objects as value to a dart map
  static Map<String, List<RestoreJobRead>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestoreJobRead>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestoreJobRead.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class RestoreJobReadStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const RestoreJobReadStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PENDING = RestoreJobReadStatusEnum._(r'PENDING');
  static const RUNNING = RestoreJobReadStatusEnum._(r'RUNNING');
  static const COMPLETED = RestoreJobReadStatusEnum._(r'COMPLETED');
  static const FAILED = RestoreJobReadStatusEnum._(r'FAILED');

  /// List of all possible values in this [enum][RestoreJobReadStatusEnum].
  static const values = <RestoreJobReadStatusEnum>[
    PENDING,
    RUNNING,
    COMPLETED,
    FAILED,
  ];

  static RestoreJobReadStatusEnum? fromJson(dynamic value) => RestoreJobReadStatusEnumTypeTransformer().decode(value);

  static List<RestoreJobReadStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreJobReadStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreJobReadStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RestoreJobReadStatusEnum] to String,
/// and [decode] dynamic data back to [RestoreJobReadStatusEnum].
class RestoreJobReadStatusEnumTypeTransformer {
  factory RestoreJobReadStatusEnumTypeTransformer() => _instance ??= const RestoreJobReadStatusEnumTypeTransformer._();

  const RestoreJobReadStatusEnumTypeTransformer._();

  String encode(RestoreJobReadStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RestoreJobReadStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RestoreJobReadStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PENDING': return RestoreJobReadStatusEnum.PENDING;
        case r'RUNNING': return RestoreJobReadStatusEnum.RUNNING;
        case r'COMPLETED': return RestoreJobReadStatusEnum.COMPLETED;
        case r'FAILED': return RestoreJobReadStatusEnum.FAILED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RestoreJobReadStatusEnumTypeTransformer] instance.
  static RestoreJobReadStatusEnumTypeTransformer? _instance;
}


