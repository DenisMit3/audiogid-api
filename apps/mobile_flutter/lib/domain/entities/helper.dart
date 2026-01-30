enum HelperType {
  toilet,
  cafe,
  drinkingWater,
  other
}

class Helper {
  final String id;
  final String title;
  final HelperType type;
  final double lat;
  final double lon;
  final String? address;
  final Map<String, dynamic> metadata;

  Helper({
    required this.id,
    required this.title,
    required this.type,
    required this.lat,
    required this.lon,
    this.address,
    this.metadata = const {},
  });
}
