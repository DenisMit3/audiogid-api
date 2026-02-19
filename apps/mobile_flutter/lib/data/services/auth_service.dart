import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_client/api.dart' as api;
import '../../core/api/api_provider.dart';
import '../../domain/entities/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authApiProvider));
});

final currentUserProvider = NotifierProvider<CurrentUserNotifier, AsyncValue<User?>>(() {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    _checkAuth();
    return const AsyncValue.loading();
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> _checkAuth() async {
    try {
      final user = await _authService.me();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loginWithSms(String phone) async {
    await _authService.loginWithSms(phone);
  }

  Future<void> verifySms(String phone, String code) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.verifySms(phone, code);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> loginWithTelegram(api.TelegramLogin data) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.loginWithTelegram(data);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}

class AuthService {
  final api.AuthApi _api;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  AuthService(this._api);

  Future<void> loginWithSms(String phone) async {
    await _api.loginSmsInit(api.PhoneInit(phone: phone));
  }

  Future<User> loginWithTelegram(api.TelegramLogin data) async {
    final res = await _api.loginTelegram(data);
    
    final token = res?.accessToken;
    final refreshToken = res?.refreshToken;
    
    if (token == null) throw Exception("No access token returned");

    await _storage.write(key: 'jwt_token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    return await me();
  }

  Future<User> verifySms(String phone, String code) async {
    final res = await _api.loginSmsVerify(
        api.PhoneVerify(phone: phone, code: code)
    );
    
    final token = res?.accessToken;
    final refreshToken = res?.refreshToken;
    
    if (token == null) throw Exception("No access token returned");

    await _storage.write(key: 'jwt_token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    return await me();
  }

  Future<User> me() async {
    final res = await _api.me();
    if (res == null) throw Exception("Failed to fetch user");
    return User(
        id: res.id ?? '',
        role: res.role ?? 'user',
        isActive: res.isActive ?? true,
    );
  }

  Future<void> logout() async {
    try {
        final refresh = await _storage.read(key: 'refresh_token');
        await _api.logout(refreshReq: api.RefreshReq(refreshToken: refresh ?? ""));
    } catch (e) {
        // Log error but proceed to clear local
    }
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return null;
    
    try {
      final res = await _api.refreshToken(api.RefreshReq(refreshToken: refresh));
      
      final newToken = res?.accessToken;
      final newRefresh = res?.refreshToken;
      
      if (newToken != null) {
          await _storage.write(key: 'jwt_token', value: newToken);
          if (newRefresh != null) {
            await _storage.write(key: 'refresh_token', value: newRefresh);
          }
          return newToken;
      }
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }
}
