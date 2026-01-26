//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OpsConfigCheckGet200Response {
  /// Returns a new [OpsConfigCheckGet200Response] instance.
  OpsConfigCheckGet200Response({
    this.YOOKASSA,
    this.PUBLIC_APP_BASE_URL,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  OpsConfigCheckGet200ResponseYOOKASSA? YOOKASSA;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? PUBLIC_APP_BASE_URL;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpsConfigCheckGet200Response &&
    other.YOOKASSA == YOOKASSA &&
    other.PUBLIC_APP_BASE_URL == PUBLIC_APP_BASE_URL;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (YOOKASSA == null ? 0 : YOOKASSA!.hashCode) +
    (PUBLIC_APP_BASE_URL == null ? 0 : PUBLIC_APP_BASE_URL!.hashCode);

  @override
  String toString() => 'OpsConfigCheckGet200Response[YOOKASSA=$YOOKASSA, PUBLIC_APP_BASE_URL=$PUBLIC_APP_BASE_URL]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.YOOKASSA != null) {
      json[r'YOOKASSA'] = this.YOOKASSA;
    } else {
      json[r'YOOKASSA'] = null;
    }
    if (this.PUBLIC_APP_BASE_URL != null) {
      json[r'PUBLIC_APP_BASE_URL'] = this.PUBLIC_APP_BASE_URL;
    } else {
      json[r'PUBLIC_APP_BASE_URL'] = null;
    }
    return json;
  }

  /// Returns a new [OpsConfigCheckGet200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OpsConfigCheckGet200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OpsConfigCheckGet200Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OpsConfigCheckGet200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OpsConfigCheckGet200Response(
        YOOKASSA: OpsConfigCheckGet200ResponseYOOKASSA.fromJson(json[r'YOOKASSA']),
        PUBLIC_APP_BASE_URL: mapValueOfType<bool>(json, r'PUBLIC_APP_BASE_URL'),
      );
    }
    return null;
  }

  static List<OpsConfigCheckGet200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpsConfigCheckGet200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpsConfigCheckGet200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OpsConfigCheckGet200Response> mapFromJson(dynamic json) {
    final map = <String, OpsConfigCheckGet200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OpsConfigCheckGet200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OpsConfigCheckGet200Response-objects as value to a dart map
  static Map<String, List<OpsConfigCheckGet200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OpsConfigCheckGet200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OpsConfigCheckGet200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

