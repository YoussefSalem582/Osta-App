import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/shared/extensions/context_ext.dart';

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
   await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    context.go(OnboardingPage.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(
              'صلح عربيتك في دقائق',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
