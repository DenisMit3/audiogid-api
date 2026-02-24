import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/entitlement_grant.dart'
    as domain;
import 'package:mobile_flutter/domain/repositories/entitlement_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'entitlement_repository.g.dart';

class OfflineEntitlementRepository implements EntitlementRepository {
  final api.BillingApi _api;
  final AppDatabase _db;

  OfflineEntitlementRepository(this._api, this._db);

  @override
  Stream<List<domain.EntitlementGrant>> watchGrants() {
    syncGrants().ignore();

    return _db.entitlementDao.watchAllGrants().map((rows) => rows
        .map((r) => domain.EntitlementGrant(
              id: r.id,
              entitlementSlug: r.entitlementSlug,
              scope: r.scope,
              ref: r.ref,
              grantedAt: r.grantedAt,
              expiresAt: r.expiresAt,
              isActive: r.isActive,
            ))
        .toList());
  }

  @override
  Future<void> syncGrants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_anon_id');
      if (deviceId == null) return;

      // Вызываем API для получения entitlements
      final grants = await _api.getEntitlements(deviceId);

      if (grants != null && grants.isNotEmpty) {
        // Сохраняем в локальную БД
        await _db.entitlementDao.replaceAllGrants(grants
            .map((g) => EntitlementGrantsCompanion.insert(
                  id: g.id ?? '',
                  entitlementSlug: g.entitlementSlug ?? '',
                  scope: g.scope ?? '',
                  ref: Value(g.ref),
                  grantedAt: g.grantedAt ?? DateTime.now(),
                  expiresAt: Value(g.expiresAt),
                  isActive: g.isActive ?? true,
                ))
            .toList());
      }
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      print('Sync Grants Error: ${appError.message}');
    }
  }
}

@riverpod
EntitlementRepository entitlementRepository(Ref ref) {
  return OfflineEntitlementRepository(
    ref.watch(billingApiProvider),
    ref.watch(appDatabaseProvider),
  );
}

@riverpod
Stream<List<domain.EntitlementGrant>> entitlementGrants(Ref ref) {
  return ref.watch(entitlementRepositoryProvider).watchGrants();
}
