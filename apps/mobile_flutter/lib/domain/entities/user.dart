class User {
  final String id;
  final String role;
  final bool isActive;

  User({required this.id, required this.role, required this.isActive});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'] ?? 'user',
      isActive: json['is_active'] ?? true,
    );
  }
}
