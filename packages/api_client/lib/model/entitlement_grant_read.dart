//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EntitlementGrantRead {
  /// Returns a new [EntitlementGrantRead] instance.
  EntitlementGrantRead({
    this.id,
    this.entitlementSlug,
    this.scope,
    this.ref,
    this.grantedAt,
    this.expiresAt,
    this.isActive,
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
  String? entitlementSlug;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? scope;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ref;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? grantedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? expiresAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EntitlementGrantRead &&
    other.id == id &&
    other.entitlementSlug == entitlementSlug &&
    other.scope == scope &&
    other.ref == ref &&
    other.grantedAt == grantedAt &&
    other.expiresAt == expiresAt &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (entitlementSlug == null ? 0 : entitlementSlug!.hashCode) +
    (scope == null ? 0 : scope!.hashCode) +
    (ref == null ? 0 : ref!.hashCode) +
    (grantedAt == null ? 0 : grantedAt!.hashCode) +
    (expiresAt == null ? 0 : expiresAt!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'EntitlementGrantRead[id=$id, entitlementSlug=$entitlementSlug, scope=$scope, ref=$ref, grantedAt=$grantedAt, expiresAt=$expiresAt, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.entitlementSlug != null) {
      json[r'entitlement_slug'] = this.entitlementSlug;
    } else {
      json[r'entitlement_slug'] = null;
    }
    if (this.scope != null) {
      json[r'scope'] = this.scope;
    } else {
      json[r'scope'] = null;
    }
    if (this.ref != null) {
      json[r'ref'] = this.ref;
    } else {
      json[r'ref'] = null;
    }
    if (this.grantedAt != null) {
      json[r'granted_at'] = this.grantedAt!.toUtc().toIso8601String();
    } else {
      json[r'granted_at'] = null;
    }
    if (this.expiresAt != null) {
      json[r'expires_at'] = this.expiresAt!.toUtc().toIso8601String();
    } else {
      json[r'expires_at'] = null;
    }
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    return json;
  }

  /// Returns a new [EntitlementGrantRead] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EntitlementGrantRead? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EntitlementGrantRead[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EntitlementGrantRead[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EntitlementGrantRead(
        id: mapValueOfType<String>(json, r'id'),
        entitlementSlug: mapValueOfType<String>(json, r'entitlement_slug'),
        scope: mapValueOfType<String>(json, r'scope'),
        ref: mapValueOfType<String>(json, r'ref'),
        grantedAt: mapDateTime(json, r'granted_at', r''),
        expiresAt: mapDateTime(json, r'expires_at', r''),
        isActive: mapValueOfType<bool>(json, r'is_active'),
      );
    }
    return null;
  }

  static List<EntitlementGrantRead> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EntitlementGrantRead>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntitlementGrantRead.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EntitlementGrantRead> mapFromJson(dynamic json) {
    final map = <String, EntitlementGrantRead>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EntitlementGrantRead.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EntitlementGrantRead-objects as value to a dart map
  static Map<String, List<EntitlementGrantRead>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EntitlementGrantRead>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EntitlementGrantRead.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

