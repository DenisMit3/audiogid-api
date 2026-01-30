//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Narration {
  /// Returns a new [Narration] instance.
  Narration({
    this.id,
    this.url,
    this.locale,
    this.durationSeconds,
    this.transcript,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? url;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? locale;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? durationSeconds;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? transcript;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Narration &&
    other.id == id &&
    other.url == url &&
    other.locale == locale &&
    other.durationSeconds == durationSeconds &&
    other.transcript == transcript;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (url == null ? 0 : url!.hashCode) +
    (locale == null ? 0 : locale!.hashCode) +
    (durationSeconds == null ? 0 : durationSeconds!.hashCode) +
    (transcript == null ? 0 : transcript!.hashCode);

  @override
  String toString() => 'Narration[id=$id, url=$url, locale=$locale, durationSeconds=$durationSeconds, transcript=$transcript]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    if (this.locale != null) {
      json[r'locale'] = this.locale;
    } else {
      json[r'locale'] = null;
    }
    if (this.durationSeconds != null) {
      json[r'duration_seconds'] = this.durationSeconds;
    } else {
      json[r'duration_seconds'] = null;
    }
    if (this.transcript != null) {
      json[r'transcript'] = this.transcript;
    } else {
      json[r'transcript'] = null;
    }
    return json;
  }

  /// Returns a new [Narration] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Narration? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Narration[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Narration[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Narration(
        id: mapValueOfType<String>(json, r'id'),
        url: mapValueOfType<String>(json, r'url'),
        locale: mapValueOfType<String>(json, r'locale'),
        durationSeconds: num.parse('${json[r'duration_seconds']}'),
        transcript: mapValueOfType<String>(json, r'transcript'),
      );
    }
    return null;
  }

  static List<Narration> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Narration>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Narration.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Narration> mapFromJson(dynamic json) {
    final map = <String, Narration>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Narration.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Narration-objects as value to a dart map
  static Map<String, List<Narration>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Narration>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Narration.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

