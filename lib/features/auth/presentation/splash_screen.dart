import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/local/hive_setup.dart';
import '../data/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });

    // Start animation or timer
    // If no lottie file, we just use a timer
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    // Check Onboarding
    final settingsBox = Hive.box<dynamic>(HiveSetup.settingsBoxName);
    final bool hasSeenOnboarding = settingsBox.get(
      'hasSeenOnboarding',
      defaultValue: false,
    );

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }

    // Check Auth
    // Wait for Firebase to restore persisted session
    final user = await ref.read(authStateProvider.future);

    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Lottie
            // Lottie.asset(
            //   'assets/animations/splash.json',
            //   controller: _controller,
            //   onLoaded: (composition) {
            //     _controller.duration = composition.duration;
            //     _controller.forward();
            //   },
            // ),
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'MicroWins',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
