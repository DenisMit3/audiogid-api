//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TourSnippet {
  /// Returns a new [TourSnippet] instance.
  TourSnippet({
    this.id,
    this.citySlug,
    this.titleRu,
    this.descriptionRu,
    this.coverImage,
    this.durationMinutes,
    this.distanceKm,
    this.tourType,
    this.difficulty,
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
  String? citySlug;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? titleRu;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? descriptionRu;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? coverImage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? durationMinutes;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? distanceKm;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tourType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? difficulty;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TourSnippet &&
    other.id == id &&
    other.citySlug == citySlug &&
    other.titleRu == titleRu &&
    other.descriptionRu == descriptionRu &&
    other.coverImage == coverImage &&
    other.durationMinutes == durationMinutes &&
    other.distanceKm == distanceKm &&
    other.tourType == tourType &&
    other.difficulty == difficulty;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (citySlug == null ? 0 : citySlug!.hashCode) +
    (titleRu == null ? 0 : titleRu!.hashCode) +
    (descriptionRu == null ? 0 : descriptionRu!.hashCode) +
    (coverImage == null ? 0 : coverImage!.hashCode) +
    (durationMinutes == null ? 0 : durationMinutes!.hashCode) +
    (distanceKm == null ? 0 : distanceKm!.hashCode) +
    (tourType == null ? 0 : tourType!.hashCode) +
    (difficulty == null ? 0 : difficulty!.hashCode);

  @override
  String toString() => 'TourSnippet[id=$id, citySlug=$citySlug, titleRu=$titleRu, descriptionRu=$descriptionRu, coverImage=$coverImage, durationMinutes=$durationMinutes, distanceKm=$distanceKm, tourType=$tourType, difficulty=$difficulty]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.citySlug != null) {
      json[r'city_slug'] = this.citySlug;
    } else {
      json[r'city_slug'] = null;
    }
    if (this.titleRu != null) {
      json[r'title_ru'] = this.titleRu;
    } else {
      json[r'title_ru'] = null;
    }
    if (this.descriptionRu != null) {
      json[r'description_ru'] = this.descriptionRu;
    } else {
      json[r'description_ru'] = null;
    }
    if (this.coverImage != null) {
      json[r'cover_image'] = this.coverImage;
    } else {
      json[r'cover_image'] = null;
    }
    if (this.durationMinutes != null) {
      json[r'duration_minutes'] = this.durationMinutes;
    } else {
      json[r'duration_minutes'] = null;
    }
    if (this.distanceKm != null) {
      json[r'distance_km'] = this.distanceKm;
    } else {
      json[r'distance_km'] = null;
    }
    if (this.tourType != null) {
      json[r'tour_type'] = this.tourType;
    } else {
      json[r'tour_type'] = null;
    }
    if (this.difficulty != null) {
      json[r'difficulty'] = this.difficulty;
    } else {
      json[r'difficulty'] = null;
    }
    return json;
  }

  /// Returns a new [TourSnippet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TourSnippet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TourSnippet[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TourSnippet[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TourSnippet(
        id: mapValueOfType<String>(json, r'id'),
        citySlug: mapValueOfType<String>(json, r'city_slug'),
        titleRu: mapValueOfType<String>(json, r'title_ru'),
        descriptionRu: mapValueOfType<String>(json, r'description_ru'),
        coverImage: mapValueOfType<String>(json, r'cover_image'),
        durationMinutes: mapValueOfType<int>(json, r'duration_minutes'),
        distanceKm: num.parse('${json[r'distance_km']}'),
        tourType: mapValueOfType<String>(json, r'tour_type'),
        difficulty: mapValueOfType<String>(json, r'difficulty'),
      );
    }
    return null;
  }

  static List<TourSnippet> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TourSnippet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TourSnippet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TourSnippet> mapFromJson(dynamic json) {
    final map = <String, TourSnippet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TourSnippet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TourSnippet-objects as value to a dart map
  static Map<String, List<TourSnippet>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TourSnippet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TourSnippet.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

