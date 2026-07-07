import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_state.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Root widget. Wires the themes (light + dark, user-persisted mode), the
/// [SessionController] (locale + first-run routing) and the [AppRouter], and
/// surfaces the wrong-shell auto-correction toast at the app level.
class OstaApp extends StatelessWidget {
  const OstaApp({super.key});

  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeModeController>()),
        BlocProvider.value(value: getIt<SessionController>()),
      ],
      child: BlocBuilder<ThemeModeController, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<SessionController, SessionState>(
            buildWhen: (previous, current) => previous.locale != current.locale,
            builder: (context, session) => MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              locale: session.locale,
              scaffoldMessengerKey: _messengerKey,
              routerConfig: getIt<AppRouter>().router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => _CorrectionToast(child: child),
            ),
          );
        },
      ),
    );
  }
}

/// Shows a one-shot toast when login healed a wrong-shell choice
/// (`activeRole` overwritten from `me.type`).
class _CorrectionToast extends StatelessWidget {
  const _CorrectionToast({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionController, SessionState>(
      listenWhen: (previous, current) =>
          current.correctedRole != null &&
          previous.correctedRole != current.correctedRole,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.roleCorrected)));
        context.read<SessionController>().acknowledgeCorrection();
      },
      child: child ?? const SizedBox.shrink(),
    );
  }
}
