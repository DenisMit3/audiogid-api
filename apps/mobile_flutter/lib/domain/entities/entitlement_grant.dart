class EntitlementGrant {
  final String id;
  final String entitlementSlug;
  final String scope;
  final String? ref;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final bool isActive;

  EntitlementGrant({
    required this.id,
    required this.entitlementSlug,
    required this.scope,
    this.ref,
    required this.grantedAt,
    this.expiresAt,
    required this.isActive,
  });
}
