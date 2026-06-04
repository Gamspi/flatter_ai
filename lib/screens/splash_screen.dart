import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_colors.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final service = ref.read(authServiceProvider);
    final isValid = await service.isSessionValid();

    if (!mounted) return;

    if (!isValid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final isTokenValid = await service.verifyToken();
    if (!mounted) return;

    if (!isTokenValid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final LocalAuthentication localAuth = LocalAuthentication();
    bool canBio = false;
    try {
      canBio = await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    } catch (_) {}
    if (!mounted) return;

    if (canBio) {
      try {
        final ok = await localAuth.authenticate(
          localizedReason: 'Войдите в приложение',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (ok && mounted) {
          final name = await service.getStoredUserName() ?? '';
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen(username: name)),
            );
          }
        } else if (!ok && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } else if (mounted) {
      final name = await service.getStoredUserName() ?? '';
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(username: name)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.lime),
      ),
    );
  }
}
