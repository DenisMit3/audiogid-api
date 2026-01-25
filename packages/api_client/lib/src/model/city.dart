class City {
  final String id;
  final String slug;
  final String nameRu;
  final bool isActive;

  City({
    required this.id,
    required this.slug,
    required this.nameRu,
    required this.isActive,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'] as String,
    slug: json['slug'] as String,
    nameRu: json['name_ru'] as String,
    isActive: json['is_active'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name_ru': nameRu,
    'is_active': isActive,
  };
}
