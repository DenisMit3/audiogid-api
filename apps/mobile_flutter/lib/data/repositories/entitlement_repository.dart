import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/entitlement_grant.dart';
import 'package:mobile_flutter/domain/repositories/entitlement_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'entitlement_repository.g.dart';

class OfflineEntitlementRepository implements EntitlementRepository {
  final api.BillingApi _api;
  final AppDatabase _db;

  OfflineEntitlementRepository(this._api, this._db);

  @override
  Stream<List<EntitlementGrant>> watchGrants() {
    syncGrants().ignore();
    
    return _db.entitlementDao.watchAllGrants().map((rows) => rows.map((r) => EntitlementGrant(
      id: r.id,
      entitlementSlug: r.entitlementSlug,
      scope: r.scope,
      ref: r.ref,
      grantedAt: r.grantedAt,
      expiresAt: r.expiresAt,
      isActive: r.isActive,
    )).toList());
  }

  @override
  Future<void> syncGrants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_anon_id');
      if (deviceId == null) return;

      final response = await _api.billingEntitlementsGetWithHttpInfo(deviceId);
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final grants = await _api.apiClient.deserializeAsync(response.body, 'List<EntitlementGrantRead>') as List;
      final companions = grants.cast<api.EntitlementGrantRead>().map((g) => EntitlementGrantsCompanion(
        id: Value(g.id!),
        entitlementSlug: Value(g.entitlementSlug!),
        scope: Value(g.scope!),
        ref: Value(g.ref),
        grantedAt: Value(g.grantedAt!),
        expiresAt: Value(g.expiresAt),
        isActive: Value(g.isActive!),
      )).toList();

      await _db.entitlementDao.replaceAllGrants(companions);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync Entitlements Error: ${appError.message}');
    }
  }
}

@riverpod
EntitlementRepository entitlementRepository(EntitlementRepositoryRef ref) {
  return OfflineEntitlementRepository(
    ref.watch(billingApiProvider),
    ref.watch(appDatabaseProvider),
  );
}

@riverpod
Stream<List<EntitlementGrant>> entitlementGrants(EntitlementGrantsRef ref) {
  return ref.watch(entitlementRepositoryProvider).watchGrants();
}
