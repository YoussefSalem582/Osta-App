import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/features/customer/profile/presentation/profile_screen.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// First screen shown on launch; hands off to the first-run role selection.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const path = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go(ProfileScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.logo, width: 120),
            const SizedBox(height: 24),
            Text(
              context.l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
