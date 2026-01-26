/// Local entitlement model for app-side caching.
class Entitlement {
  final String id;
  final String slug;
  final String scope;
  final String ref;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final bool isActive;

  Entitlement({
    required this.id,
    required this.slug,
    required this.scope,
    required this.ref,
    required this.grantedAt,
    this.expiresAt,
    this.isActive = true,
  });

  factory Entitlement.fromApiModel(dynamic apiModel) {
    return Entitlement(
      id: apiModel.id ?? '',
      slug: apiModel.entitlementSlug ?? '',
      scope: apiModel.scope ?? '',
      ref: apiModel.ref ?? '',
      grantedAt: apiModel.grantedAt ?? DateTime.now(),
      expiresAt: apiModel.expiresAt,
      isActive: apiModel.isActive ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'scope': scope,
    'ref': ref,
    'grantedAt': grantedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'isActive': isActive,
  };

  factory Entitlement.fromJson(Map<String, dynamic> json) => Entitlement(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    scope: json['scope'] ?? '',
    ref: json['ref'] ?? '',
    grantedAt: DateTime.parse(json['grantedAt']),
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    isActive: json['isActive'] ?? true,
  );

  /// Check if this entitlement grants access to given content (city/tour/poi).
  bool grantsAccessTo(String contentRef, String contentScope) {
    if (!isActive) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    
    // City scope grants access to all content in that city
    if (scope == 'city' && contentScope == 'city' && ref == contentRef) return true;
    if (scope == 'city' && contentScope != 'city') {
      // For tour/poi, check if their city matches
      // This requires additional context; for now, trust server-side check
      return true; 
    }
    if (scope == 'tour' && contentScope == 'tour' && ref == contentRef) return true;
    
    return false;
  }
}
