import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/constants/app_images.dart';
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

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<SessionController>().bootstrap());
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
