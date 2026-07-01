import 'package:flutter/material.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/theme/app_theme.dart';

/// Root widget. Wires theme, localizations and the [AppRouter] (splash → role).
class OstaApp extends StatelessWidget {
  const OstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: getIt<AppRouter>().router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
