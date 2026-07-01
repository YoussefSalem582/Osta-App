import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/theme/osta_theme.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';

/// Root widget. Wires the Osta themes (light + dark, user-persisted mode),
/// localizations and the [AppRouter] (splash → role).
class OstaApp extends StatelessWidget {
  const OstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ThemeModeController>(),
      child: BlocBuilder<ThemeModeController, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: OstaTheme.light(),
          darkTheme: OstaTheme.dark(),
          themeMode: themeMode,
          routerConfig: getIt<AppRouter>().router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
