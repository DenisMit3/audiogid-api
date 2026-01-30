//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TelegramLogin {
  /// Returns a new [TelegramLogin] instance.
  TelegramLogin({
    required this.id,
    this.firstName,
    this.username,
    this.photoUrl,
    required this.authDate,
    required this.hash,
  });

  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firstName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? username;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? photoUrl;

  String authDate;

  String hash;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TelegramLogin &&
    other.id == id &&
    other.firstName == firstName &&
    other.username == username &&
    other.photoUrl == photoUrl &&
    other.authDate == authDate &&
    other.hash == hash;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (firstName == null ? 0 : firstName!.hashCode) +
    (username == null ? 0 : username!.hashCode) +
    (photoUrl == null ? 0 : photoUrl!.hashCode) +
    (authDate.hashCode) +
    (hash.hashCode);

  @override
  String toString() => 'TelegramLogin[id=$id, firstName=$firstName, username=$username, photoUrl=$photoUrl, authDate=$authDate, hash=$hash]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.firstName != null) {
      json[r'first_name'] = this.firstName;
    } else {
      json[r'first_name'] = null;
    }
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
    }
    if (this.photoUrl != null) {
      json[r'photo_url'] = this.photoUrl;
    } else {
      json[r'photo_url'] = null;
    }
      json[r'auth_date'] = this.authDate;
      json[r'hash'] = this.hash;
    return json;
  }

  /// Returns a new [TelegramLogin] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TelegramLogin? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TelegramLogin[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TelegramLogin[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TelegramLogin(
        id: mapValueOfType<String>(json, r'id')!,
        firstName: mapValueOfType<String>(json, r'first_name'),
        username: mapValueOfType<String>(json, r'username'),
        photoUrl: mapValueOfType<String>(json, r'photo_url'),
        authDate: mapValueOfType<String>(json, r'auth_date')!,
        hash: mapValueOfType<String>(json, r'hash')!,
      );
    }
    return null;
  }

  static List<TelegramLogin> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TelegramLogin>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TelegramLogin.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TelegramLogin> mapFromJson(dynamic json) {
    final map = <String, TelegramLogin>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TelegramLogin.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TelegramLogin-objects as value to a dart map
  static Map<String, List<TelegramLogin>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TelegramLogin>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TelegramLogin.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'auth_date',
    'hash',
  };
}

