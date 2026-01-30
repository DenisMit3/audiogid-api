//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PresignRequest {
  /// Returns a new [PresignRequest] instance.
  PresignRequest({
    required this.filename,
    required this.contentType,
    this.entityType,
    this.entityId,
  });

  String filename;

  String contentType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? entityType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? entityId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PresignRequest &&
    other.filename == filename &&
    other.contentType == contentType &&
    other.entityType == entityType &&
    other.entityId == entityId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (filename.hashCode) +
    (contentType.hashCode) +
    (entityType == null ? 0 : entityType!.hashCode) +
    (entityId == null ? 0 : entityId!.hashCode);

  @override
  String toString() => 'PresignRequest[filename=$filename, contentType=$contentType, entityType=$entityType, entityId=$entityId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'filename'] = this.filename;
      json[r'content_type'] = this.contentType;
    if (this.entityType != null) {
      json[r'entity_type'] = this.entityType;
    } else {
      json[r'entity_type'] = null;
    }
    if (this.entityId != null) {
      json[r'entity_id'] = this.entityId;
    } else {
      json[r'entity_id'] = null;
    }
    return json;
  }

  /// Returns a new [PresignRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PresignRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PresignRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PresignRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PresignRequest(
        filename: mapValueOfType<String>(json, r'filename')!,
        contentType: mapValueOfType<String>(json, r'content_type')!,
        entityType: mapValueOfType<String>(json, r'entity_type'),
        entityId: mapValueOfType<String>(json, r'entity_id'),
      );
    }
    return null;
  }

  static List<PresignRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PresignRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PresignRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PresignRequest> mapFromJson(dynamic json) {
    final map = <String, PresignRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PresignRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PresignRequest-objects as value to a dart map
  static Map<String, List<PresignRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PresignRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PresignRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'filename',
    'content_type',
  };
}

