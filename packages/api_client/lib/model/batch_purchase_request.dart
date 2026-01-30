//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BatchPurchaseRequest {
  /// Returns a new [BatchPurchaseRequest] instance.
  BatchPurchaseRequest({
    this.poiIds = const [],
    this.tourIds = const [],
    required this.deviceAnonId,
  });

  List<String> poiIds;

  List<String> tourIds;

  String deviceAnonId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BatchPurchaseRequest &&
    _deepEquality.equals(other.poiIds, poiIds) &&
    _deepEquality.equals(other.tourIds, tourIds) &&
    other.deviceAnonId == deviceAnonId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (poiIds.hashCode) +
    (tourIds.hashCode) +
    (deviceAnonId.hashCode);

  @override
  String toString() => 'BatchPurchaseRequest[poiIds=$poiIds, tourIds=$tourIds, deviceAnonId=$deviceAnonId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'poi_ids'] = this.poiIds;
      json[r'tour_ids'] = this.tourIds;
      json[r'device_anon_id'] = this.deviceAnonId;
    return json;
  }

  /// Returns a new [BatchPurchaseRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BatchPurchaseRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BatchPurchaseRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BatchPurchaseRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BatchPurchaseRequest(
        poiIds: json[r'poi_ids'] is Iterable
            ? (json[r'poi_ids'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        tourIds: json[r'tour_ids'] is Iterable
            ? (json[r'tour_ids'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        deviceAnonId: mapValueOfType<String>(json, r'device_anon_id')!,
      );
    }
    return null;
  }

  static List<BatchPurchaseRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BatchPurchaseRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BatchPurchaseRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BatchPurchaseRequest> mapFromJson(dynamic json) {
    final map = <String, BatchPurchaseRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BatchPurchaseRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BatchPurchaseRequest-objects as value to a dart map
  static Map<String, List<BatchPurchaseRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BatchPurchaseRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BatchPurchaseRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'device_anon_id',
  };
}

