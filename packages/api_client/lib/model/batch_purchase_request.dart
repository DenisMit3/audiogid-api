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
  static BatchPurchaseRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return BatchPurchaseRequest(
        poiIds: json[r'poi_ids'] is List ? (json[r'poi_ids'] as List).cast<String>() : const [],
        tourIds: json[r'tour_ids'] is List ? (json[r'tour_ids'] as List).cast<String>() : const [],
        deviceAnonId: mapValueOfType<String>(json, r'device_anon_id')!,
      );
    }
    return null;
  }
}
