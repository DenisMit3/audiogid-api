class City {
  final String id;
  final String slug;
  final String nameRu;
  final bool isActive;
  final DateTime? updatedAt;

  City({
    required this.id,
    required this.slug,
    required this.nameRu,
    required this.isActive,
    this.updatedAt,
  });
}
