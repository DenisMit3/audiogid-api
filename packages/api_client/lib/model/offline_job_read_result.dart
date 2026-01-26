//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OfflineJobReadResult {
  /// Returns a new [OfflineJobReadResult] instance.
  OfflineJobReadResult({
    this.manifestUrl,
    this.contentHash,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? manifestUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? contentHash;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OfflineJobReadResult &&
    other.manifestUrl == manifestUrl &&
    other.contentHash == contentHash;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (manifestUrl == null ? 0 : manifestUrl!.hashCode) +
    (contentHash == null ? 0 : contentHash!.hashCode);

  @override
  String toString() => 'OfflineJobReadResult[manifestUrl=$manifestUrl, contentHash=$contentHash]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.manifestUrl != null) {
      json[r'manifest_url'] = this.manifestUrl;
    } else {
      json[r'manifest_url'] = null;
    }
    if (this.contentHash != null) {
      json[r'content_hash'] = this.contentHash;
    } else {
      json[r'content_hash'] = null;
    }
    return json;
  }

  /// Returns a new [OfflineJobReadResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OfflineJobReadResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OfflineJobReadResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OfflineJobReadResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OfflineJobReadResult(
        manifestUrl: mapValueOfType<String>(json, r'manifest_url'),
        contentHash: mapValueOfType<String>(json, r'content_hash'),
      );
    }
    return null;
  }

  static List<OfflineJobReadResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OfflineJobReadResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OfflineJobReadResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OfflineJobReadResult> mapFromJson(dynamic json) {
    final map = <String, OfflineJobReadResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OfflineJobReadResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OfflineJobReadResult-objects as value to a dart map
  static Map<String, List<OfflineJobReadResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OfflineJobReadResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OfflineJobReadResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

