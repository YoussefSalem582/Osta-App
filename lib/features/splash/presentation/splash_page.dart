import 'dart:async';

import 'package:flutter/material.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_colors.dart';

/// First screen on launch. Reads persisted `{token, activeRole, locale}` via
/// [SessionController.bootstrap]; the router's redirect then lands the user in
/// the right place (language → chooser → auth → shell, or straight to a shell).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

final class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    // Branding hold, then read persisted {token, activeRole, locale}. The
    // router's redirect (keyed on SessionController state via the refresh
    // listenable) reacts to the emitted state and leaves the splash on its
    // own — no manual navigation.
    await Future<void>.delayed(const Duration(seconds: 2));
    await getIt<SessionController>().bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.logo,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'صلح عربيتك في دقائق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
