import '../entities/entitlement_grant.dart';

abstract class EntitlementRepository {
  Stream<List<EntitlementGrant>> watchGrants();
  Future<void> syncGrants();
}
