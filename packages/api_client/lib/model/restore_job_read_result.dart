//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestoreJobReadResult {
  /// Returns a new [RestoreJobReadResult] instance.
  RestoreJobReadResult({
    this.platform,
    this.grantsCreated,
    this.grantsExisting,
    this.grantsTotal,
    this.failedCount,
    this.items = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? platform;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? grantsCreated;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? grantsExisting;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? grantsTotal;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? failedCount;

  List<RestoreItemResult> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestoreJobReadResult &&
    other.platform == platform &&
    other.grantsCreated == grantsCreated &&
    other.grantsExisting == grantsExisting &&
    other.grantsTotal == grantsTotal &&
    other.failedCount == failedCount &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (platform == null ? 0 : platform!.hashCode) +
    (grantsCreated == null ? 0 : grantsCreated!.hashCode) +
    (grantsExisting == null ? 0 : grantsExisting!.hashCode) +
    (grantsTotal == null ? 0 : grantsTotal!.hashCode) +
    (failedCount == null ? 0 : failedCount!.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'RestoreJobReadResult[platform=$platform, grantsCreated=$grantsCreated, grantsExisting=$grantsExisting, grantsTotal=$grantsTotal, failedCount=$failedCount, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.platform != null) {
      json[r'platform'] = this.platform;
    } else {
      json[r'platform'] = null;
    }
    if (this.grantsCreated != null) {
      json[r'grants_created'] = this.grantsCreated;
    } else {
      json[r'grants_created'] = null;
    }
    if (this.grantsExisting != null) {
      json[r'grants_existing'] = this.grantsExisting;
    } else {
      json[r'grants_existing'] = null;
    }
    if (this.grantsTotal != null) {
      json[r'grants_total'] = this.grantsTotal;
    } else {
      json[r'grants_total'] = null;
    }
    if (this.failedCount != null) {
      json[r'failed_count'] = this.failedCount;
    } else {
      json[r'failed_count'] = null;
    }
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [RestoreJobReadResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestoreJobReadResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestoreJobReadResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestoreJobReadResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestoreJobReadResult(
        platform: mapValueOfType<String>(json, r'platform'),
        grantsCreated: mapValueOfType<int>(json, r'grants_created'),
        grantsExisting: mapValueOfType<int>(json, r'grants_existing'),
        grantsTotal: mapValueOfType<int>(json, r'grants_total'),
        failedCount: mapValueOfType<int>(json, r'failed_count'),
        items: RestoreItemResult.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<RestoreJobReadResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreJobReadResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreJobReadResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestoreJobReadResult> mapFromJson(dynamic json) {
    final map = <String, RestoreJobReadResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestoreJobReadResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestoreJobReadResult-objects as value to a dart map
  static Map<String, List<RestoreJobReadResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestoreJobReadResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestoreJobReadResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

