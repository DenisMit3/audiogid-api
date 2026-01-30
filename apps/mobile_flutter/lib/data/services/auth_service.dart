import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_client/api.dart';
import '../../core/api/api_provider.dart';
import '../../domain/entities/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authApiProvider));
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  return CurrentUserNotifier(ref.watch(authServiceProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
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

  Future<void> loginWithTelegram(TelegramLogin data) async {
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
  final AuthApi _api;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  AuthService(this._api);

  Future<void> loginWithSms(String phone) async {
    await _api.loginSmsInit(phoneInit: PhoneInit((b) => b..phone = phone));
  }

  Future<User> loginWithTelegram(TelegramLogin data) async {
    final res = await _api.loginTelegram(telegramLogin: data);
    
    final token = res.data?.accessToken;
    final refreshToken = res.data?.refreshToken;
    
    if (token == null) throw Exception("No access token returned");

    await _storage.write(key: 'jwt_token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    return await me();
  }

  Future<User> verifySms(String phone, String code) async {
    final res = await _api.loginSmsVerify(
        phoneVerify: PhoneVerify((b) => b
          ..phone = phone
          ..code = code
        )
    );
    
    final token = res.data?.accessToken;
    final refreshToken = res.data?.refreshToken;
    
    if (token == null) throw Exception("No access token returned");

    await _storage.write(key: 'jwt_token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    return await me();
  }

  Future<User> me() async {
    final res = await _api.me();
    if (res.data == null) throw Exception("Failed to fetch user");
    // Convert generated User DTO to efficient internal User entity if needed, 
    // or if they are same, just return. Assuming User entity matches or is the DTO.
    // The previous code used User.fromJson(res.data) so it implies a manual User class.
    // We should probably Map it.
    // However, if the generated client replaces the manual User, we use that.
    // Assuming for now we map it or the types align if generated in same namespace (unlikely).
    // Let's assume manual mapping is safer given existing code structure.
    return User(
        id: res.data!.id,
        role: res.data!.role ?? 'user',
        isActive: res.data!.isActive ?? true,
    );
  }

  Future<void> logout() async {
    try {
        final refresh = await _storage.read(key: 'refresh_token');
        await _api.logout(refreshReq: RefreshReq((b) => b..refreshToken = refresh ?? ""));
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
      // Note: This method re-uses the main API client which has interceptors.
      // This might cause loop if interceptor calls this.
      // But AuthService usually is called by UI or logic, not by Interceptor directly (Interceptor does its own refresh).
      // However, to match the Interceptor's raw logic avoiding loops is safer.
      // But here we are in Service.
      
      final res = await _api.refreshToken(refreshReq: RefreshReq((b) => b..refreshToken = refresh));
      
      final newToken = res.data?.accessToken;
      final newRefresh = res.data?.refreshToken;
      
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
