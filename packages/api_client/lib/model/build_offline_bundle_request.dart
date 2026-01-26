//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BuildOfflineBundleRequest {
  /// Returns a new [BuildOfflineBundleRequest] instance.
  BuildOfflineBundleRequest({
    required this.citySlug,
    required this.idempotencyKey,
    this.type = 'full_city',
  });

  String citySlug;

  String idempotencyKey;

  String type;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BuildOfflineBundleRequest &&
    other.citySlug == citySlug &&
    other.idempotencyKey == idempotencyKey &&
    other.type == type;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (citySlug.hashCode) +
    (idempotencyKey.hashCode) +
    (type.hashCode);

  @override
  String toString() => 'BuildOfflineBundleRequest[citySlug=$citySlug, idempotencyKey=$idempotencyKey, type=$type]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'city_slug'] = this.citySlug;
      json[r'idempotency_key'] = this.idempotencyKey;
      json[r'type'] = this.type;
    return json;
  }

  /// Returns a new [BuildOfflineBundleRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BuildOfflineBundleRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BuildOfflineBundleRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BuildOfflineBundleRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BuildOfflineBundleRequest(
        citySlug: mapValueOfType<String>(json, r'city_slug')!,
        idempotencyKey: mapValueOfType<String>(json, r'idempotency_key')!,
        type: mapValueOfType<String>(json, r'type') ?? 'full_city',
      );
    }
    return null;
  }

  static List<BuildOfflineBundleRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BuildOfflineBundleRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BuildOfflineBundleRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BuildOfflineBundleRequest> mapFromJson(dynamic json) {
    final map = <String, BuildOfflineBundleRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BuildOfflineBundleRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BuildOfflineBundleRequest-objects as value to a dart map
  static Map<String, List<BuildOfflineBundleRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BuildOfflineBundleRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BuildOfflineBundleRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'city_slug',
    'idempotency_key',
  };
}

