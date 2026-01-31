class Poi {
  final String id;
  final String citySlug;
  final String titleRu;
  final String? descriptionRu;
  final double lat;
  final double lon;
  final String? previewAudioUrl;
  final bool hasAccess;
  final bool isFavorite;
  final String? category;
  final List<Narration> narrations;
  final List<Media> media;
  final List<PoiSource> sources;

  Poi({
    required this.id,
    required this.citySlug,
    required this.titleRu,
    this.descriptionRu,
    required this.lat,
    required this.lon,
    this.previewAudioUrl,
    required this.hasAccess,
    this.isFavorite = false,
    this.category,
    required this.narrations,
    required this.media,
    required this.sources,
  });
}

class Narration {
  final String id;
  final String url;
  final String locale;
  final double? durationSeconds;
  final String? transcript;
  final String? localPath;
  final String? kidsUrl;

  Narration({
    required this.id,
    required this.url,
    required this.locale,
    this.durationSeconds,
    this.transcript,
    this.localPath,
    this.kidsUrl,
  });
}

class Media {
  final String id;
  final String url;
  final String mediaType;
  final String? author;
  final String? sourcePageUrl;
  final String? licenseType;

  Media({
    required this.id,
    required this.url,
    required this.mediaType,
    this.author,
    this.sourcePageUrl,
    this.licenseType,
  });
}

class PoiSource {
  final String id;
  final String name;
  final String? url;

  PoiSource({
    required this.id,
    required this.name,
    this.url,
  });
}
