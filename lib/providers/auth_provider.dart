import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ─── Sentinel для отличия "не передан" от "явно null" ───────────────────────
const _sentinel = Object();

// ─── Enum ────────────────────────────────────────────────────────────────────
enum AuthStep { idle, loading, codeSent, authenticated, error }

// ─── State ───────────────────────────────────────────────────────────────────
class AuthState {
  final AuthStep step;
  final String? tempToken;
  final int expiresIn;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    required this.step,
    this.tempToken,
    this.expiresIn = 0,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStep? step,
    Object? tempToken = _sentinel,
    int? expiresIn,
    Object? errorMessage = _sentinel,
    Object? user = _sentinel,
  }) {
    return AuthState(
      step: step ?? this.step,
      tempToken: identical(tempToken, _sentinel)
          ? this.tempToken
          : tempToken as String?,
      expiresIn: expiresIn ?? this.expiresIn,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      user: identical(user, _sentinel) ? this.user : user as UserModel?,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(step: AuthStep.idle);

  AuthService get _service => ref.read(authServiceProvider);

  Future<void> loginStep1(String phone, String password) async {
    state = const AuthState(step: AuthStep.loading);
    try {
      final result = await _service.login(phone, password);
      state = AuthState(
        step: AuthStep.codeSent,
        tempToken: result.tempToken,
        expiresIn: result.expiresIn,
      );
    } on AuthException catch (e) {
      state = AuthState(
        step: AuthStep.error,
        errorMessage: _mapError(e),
      );
    } catch (_) {
      state = const AuthState(
        step: AuthStep.error,
        errorMessage: 'Нет соединения с сервером',
      );
    }
  }

  Future<void> loginStep2(String code) async {
    final tempToken = state.tempToken;
    if (tempToken == null) return;

    state = state.copyWith(step: AuthStep.loading, errorMessage: null);
    try {
      final user = await _service.confirm(tempToken, code);
      state = AuthState(
        step: AuthStep.authenticated,
        user: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        step: AuthStep.codeSent,
        errorMessage: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        step: AuthStep.codeSent,
        errorMessage: 'Нет соединения с сервером',
      );
    }
  }

  void resetToStep1() => state = const AuthState(step: AuthStep.idle);

  void clearError() {
    state = AuthState(
      step: state.step,
      tempToken: state.tempToken,
      expiresIn: state.expiresIn,
      user: state.user,
    );
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(step: AuthStep.idle);
  }

  String _mapError(AuthException e) {
    final msg = e.message.toLowerCase();
    switch (e.statusCode) {
      case 401:
        if (msg.contains('пароль')) return 'Неверный пароль';
        if (msg.contains('неверный код') ||
            (msg.contains('код') && msg.contains('неверн'))) {
          return 'Неверный код';
        }
        if (msg.contains('истёк') || msg.contains('истек')) {
          return 'Код истёк, запросите новый';
        }
        return 'Ошибка авторизации';
      case 404:
        return 'Пользователь не найден';
      case 502:
        return 'Сервис временно недоступен';
      default:
        return e.message;
    }
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
