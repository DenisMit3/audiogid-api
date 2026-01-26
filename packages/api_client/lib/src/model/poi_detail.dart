class PoiDetail {
  final String id;
  final String titleRu;
  final String descriptionRu;
  final double lat;
  final double lon;
  final String? previewAudioUrl;
  final List<String>? previewBullets;
  final bool hasAccess;

  PoiDetail({
    required this.id,
    required this.titleRu,
    required this.descriptionRu,
    required this.lat,
    required this.lon,
    this.previewAudioUrl,
    this.previewBullets,
    required this.hasAccess,
  });

  factory PoiDetail.fromJson(Map<String, dynamic> json) => PoiDetail(
    id: json['id'] as String,
    titleRu: json['title_ru'] as String,
    descriptionRu: json['description_ru'] as String,
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
    previewAudioUrl: json['preview_audio_url'] as String?,
    previewBullets: (json['preview_bullets'] as List<dynamic>?)?.map((e) => e as String).toList(),
    hasAccess: json['has_access'] as bool,
  );
}
