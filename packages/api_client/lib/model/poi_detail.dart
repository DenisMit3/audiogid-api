//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PoiDetail {
  /// Returns a new [PoiDetail] instance.
  PoiDetail({
    this.id,
    this.titleRu,
    this.descriptionRu,
    this.lat,
    this.lon,
    this.previewAudioUrl,
    this.previewBullets = const [],
    this.hasAccess,
    this.narrations = const [],
    this.media = const [],
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
  num? lat;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? lon;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? previewAudioUrl;

  List<String> previewBullets;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? hasAccess;

  List<Narration> narrations;

  List<Media> media;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PoiDetail &&
    other.id == id &&
    other.titleRu == titleRu &&
    other.descriptionRu == descriptionRu &&
    other.lat == lat &&
    other.lon == lon &&
    other.previewAudioUrl == previewAudioUrl &&
    _deepEquality.equals(other.previewBullets, previewBullets) &&
    other.hasAccess == hasAccess &&
    _deepEquality.equals(other.narrations, narrations) &&
    _deepEquality.equals(other.media, media);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (titleRu == null ? 0 : titleRu!.hashCode) +
    (descriptionRu == null ? 0 : descriptionRu!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lon == null ? 0 : lon!.hashCode) +
    (previewAudioUrl == null ? 0 : previewAudioUrl!.hashCode) +
    (previewBullets.hashCode) +
    (hasAccess == null ? 0 : hasAccess!.hashCode) +
    (narrations.hashCode) +
    (media.hashCode);

  @override
  String toString() => 'PoiDetail[id=$id, titleRu=$titleRu, descriptionRu=$descriptionRu, lat=$lat, lon=$lon, previewAudioUrl=$previewAudioUrl, previewBullets=$previewBullets, hasAccess=$hasAccess, narrations=$narrations, media=$media]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
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
    if (this.lat != null) {
      json[r'lat'] = this.lat;
    } else {
      json[r'lat'] = null;
    }
    if (this.lon != null) {
      json[r'lon'] = this.lon;
    } else {
      json[r'lon'] = null;
    }
    if (this.previewAudioUrl != null) {
      json[r'preview_audio_url'] = this.previewAudioUrl;
    } else {
      json[r'preview_audio_url'] = null;
    }
      json[r'preview_bullets'] = this.previewBullets;
    if (this.hasAccess != null) {
      json[r'has_access'] = this.hasAccess;
    } else {
      json[r'has_access'] = null;
    }
      json[r'narrations'] = this.narrations;
      json[r'media'] = this.media;
    return json;
  }

  /// Returns a new [PoiDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PoiDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PoiDetail[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PoiDetail[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PoiDetail(
        id: mapValueOfType<String>(json, r'id'),
        titleRu: mapValueOfType<String>(json, r'title_ru'),
        descriptionRu: mapValueOfType<String>(json, r'description_ru'),
        lat: num.parse('${json[r'lat']}'),
        lon: num.parse('${json[r'lon']}'),
        previewAudioUrl: mapValueOfType<String>(json, r'preview_audio_url'),
        previewBullets: json[r'preview_bullets'] is Iterable
            ? (json[r'preview_bullets'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        hasAccess: mapValueOfType<bool>(json, r'has_access'),
        narrations: Narration.listFromJson(json[r'narrations']),
        media: Media.listFromJson(json[r'media']),
      );
    }
    return null;
  }

  static List<PoiDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PoiDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PoiDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PoiDetail> mapFromJson(dynamic json) {
    final map = <String, PoiDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PoiDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PoiDetail-objects as value to a dart map
  static Map<String, List<PoiDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PoiDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PoiDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

