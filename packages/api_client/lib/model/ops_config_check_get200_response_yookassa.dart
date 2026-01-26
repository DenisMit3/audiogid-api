//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OpsConfigCheckGet200ResponseYOOKASSA {
  /// Returns a new [OpsConfigCheckGet200ResponseYOOKASSA] instance.
  OpsConfigCheckGet200ResponseYOOKASSA({
    this.SHOP_ID,
    this.SECRET_KEY,
    this.WEBHOOK_SECRET,
    this.WEBHOOK_PATH,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? SHOP_ID;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? SECRET_KEY;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? WEBHOOK_SECRET;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? WEBHOOK_PATH;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpsConfigCheckGet200ResponseYOOKASSA &&
    other.SHOP_ID == SHOP_ID &&
    other.SECRET_KEY == SECRET_KEY &&
    other.WEBHOOK_SECRET == WEBHOOK_SECRET &&
    other.WEBHOOK_PATH == WEBHOOK_PATH;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (SHOP_ID == null ? 0 : SHOP_ID!.hashCode) +
    (SECRET_KEY == null ? 0 : SECRET_KEY!.hashCode) +
    (WEBHOOK_SECRET == null ? 0 : WEBHOOK_SECRET!.hashCode) +
    (WEBHOOK_PATH == null ? 0 : WEBHOOK_PATH!.hashCode);

  @override
  String toString() => 'OpsConfigCheckGet200ResponseYOOKASSA[SHOP_ID=$SHOP_ID, SECRET_KEY=$SECRET_KEY, WEBHOOK_SECRET=$WEBHOOK_SECRET, WEBHOOK_PATH=$WEBHOOK_PATH]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.SHOP_ID != null) {
      json[r'SHOP_ID'] = this.SHOP_ID;
    } else {
      json[r'SHOP_ID'] = null;
    }
    if (this.SECRET_KEY != null) {
      json[r'SECRET_KEY'] = this.SECRET_KEY;
    } else {
      json[r'SECRET_KEY'] = null;
    }
    if (this.WEBHOOK_SECRET != null) {
      json[r'WEBHOOK_SECRET'] = this.WEBHOOK_SECRET;
    } else {
      json[r'WEBHOOK_SECRET'] = null;
    }
    if (this.WEBHOOK_PATH != null) {
      json[r'WEBHOOK_PATH'] = this.WEBHOOK_PATH;
    } else {
      json[r'WEBHOOK_PATH'] = null;
    }
    return json;
  }

  /// Returns a new [OpsConfigCheckGet200ResponseYOOKASSA] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OpsConfigCheckGet200ResponseYOOKASSA? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OpsConfigCheckGet200ResponseYOOKASSA[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OpsConfigCheckGet200ResponseYOOKASSA[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OpsConfigCheckGet200ResponseYOOKASSA(
        SHOP_ID: mapValueOfType<bool>(json, r'SHOP_ID'),
        SECRET_KEY: mapValueOfType<bool>(json, r'SECRET_KEY'),
        WEBHOOK_SECRET: mapValueOfType<bool>(json, r'WEBHOOK_SECRET'),
        WEBHOOK_PATH: mapValueOfType<String>(json, r'WEBHOOK_PATH'),
      );
    }
    return null;
  }

  static List<OpsConfigCheckGet200ResponseYOOKASSA> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpsConfigCheckGet200ResponseYOOKASSA>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpsConfigCheckGet200ResponseYOOKASSA.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OpsConfigCheckGet200ResponseYOOKASSA> mapFromJson(dynamic json) {
    final map = <String, OpsConfigCheckGet200ResponseYOOKASSA>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OpsConfigCheckGet200ResponseYOOKASSA.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OpsConfigCheckGet200ResponseYOOKASSA-objects as value to a dart map
  static Map<String, List<OpsConfigCheckGet200ResponseYOOKASSA>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OpsConfigCheckGet200ResponseYOOKASSA>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OpsConfigCheckGet200ResponseYOOKASSA.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

