import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/locale/locale_controller.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';

/// Root widget. Wires the Osta themes (light + dark, user-persisted mode),
/// localizations and the [AppRouter] (splash → role).
class OstaApp extends StatelessWidget {
  const OstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeModeController>()),
        BlocProvider.value(value: getIt<LocaleController>()),
      ],
      child: BlocBuilder<ThemeModeController, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleController, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                routerConfig: getIt<AppRouter>().router,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
