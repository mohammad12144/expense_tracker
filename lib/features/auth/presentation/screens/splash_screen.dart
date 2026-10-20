import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/core/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final minDelay = Future<void>.delayed(const Duration(seconds: 2));
    User? user;
    try {
      // Firebase بيسترجع الجلسة المحفوظة. إذا علق، بنكمّل بعد 6 ثواني.
      user = await ref
          .read(authStateProvider.future)
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[splash] auth state failed: $e');
    }
    await minDelay;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, user == null ? '/login' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppLogo(size: 90)),
    );
  }
}