class TourSnippet {
  final String id;
  final String citySlug;
  final String titleRu;
  final int durationMinutes;

  TourSnippet({
    required this.id,
    required this.citySlug,
    required this.titleRu,
    required this.durationMinutes,
  });

  factory TourSnippet.fromJson(Map<String, dynamic> json) => TourSnippet(
    id: json['id'] as String,
    citySlug: json['city_slug'] as String,
    titleRu: json['title_ru'] as String,
    durationMinutes: json['duration_minutes'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'city_slug': citySlug,
    'title_ru': titleRu,
    'duration_minutes': durationMinutes,
  };
}
