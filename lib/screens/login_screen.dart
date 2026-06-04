import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscurePassword = true;
  Timer? _timer;
  int _secondsLeft = 0;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsLeft = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int s) {
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next.step == AuthStep.authenticated && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: next.user?.name ?? ''),
          ),
        );
      }
      if (prev?.step != next.step && next.step == AuthStep.codeSent) {
        _startTimer(next.expiresIn);
      }
    });

    final state = ref.watch(authProvider);
    final isLoading = state.step == AuthStep.loading;
    final showStep2 =
        state.step == AuthStep.codeSent ||
        (state.step == AuthStep.loading && state.tempToken != null);

    if (showStep2) {
      return _buildStep2(state, isLoading);
    }
    return _buildStep1(state, isLoading);
  }

  Widget _buildStep1(AuthState state, bool isLoading) {
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final canSubmit = !isLoading && phone.isNotEmpty && password.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: AppColors.lime),
                  const SizedBox(height: 24),
                  Text(
                    'Вход',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneMaskFormatter],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Номер телефона',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canSubmit
                          ? () {
                              ref
                                  .read(authProvider.notifier)
                                  .loginStep1(
                                    _phoneController.text,
                                    _passwordController.text,
                                  );
                            }
                          : null,
                      child: const Text('Войти'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) ...[
            Container(color: Colors.black26),
            const Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2(AuthState state, bool isLoading) {
    final canConfirm =
        !isLoading && _codeController.text.length >= 4;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sms_outlined, size: 64, color: AppColors.lime),
              const SizedBox(height: 24),
              Text(
                'Подтверждение',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Введите 4-значный код из SMS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  letterSpacing: 8,
                  fontSize: 24,
                ),
                decoration: const InputDecoration(
                  labelText: 'Код из SMS',
                  counter: SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 8),
              if (_secondsLeft > 0) ...[
                Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
              ] else
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).resetToStep1();
                    _timer?.cancel();
                    _codeController.clear();
                  },
                  child: const Text('Получить новый код'),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canConfirm
                      ? () {
                          ref
                              .read(authProvider.notifier)
                              .loginStep2(_codeController.text);
                        }
                      : null,
                  child: const Text('Подтвердить'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).resetToStep1();
                  _codeController.clear();
                  _timer?.cancel();
                },
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
