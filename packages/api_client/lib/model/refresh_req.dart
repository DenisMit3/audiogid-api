//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RefreshReq {
  /// Returns a new [RefreshReq] instance.
  RefreshReq({
    required this.refreshToken,
  });

  String refreshToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RefreshReq &&
    other.refreshToken == refreshToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (refreshToken.hashCode);

  @override
  String toString() => 'RefreshReq[refreshToken=$refreshToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'refresh_token'] = this.refreshToken;
    return json;
  }

  /// Returns a new [RefreshReq] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RefreshReq? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RefreshReq[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RefreshReq[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RefreshReq(
        refreshToken: mapValueOfType<String>(json, r'refresh_token')!,
      );
    }
    return null;
  }

  static List<RefreshReq> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RefreshReq>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RefreshReq.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RefreshReq> mapFromJson(dynamic json) {
    final map = <String, RefreshReq>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RefreshReq.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RefreshReq-objects as value to a dart map
  static Map<String, List<RefreshReq>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RefreshReq>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RefreshReq.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'refresh_token',
  };
}

