import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/network/social_token_exchange.dart';

import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/auth/data/auth_repository_impl.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';
import 'package:osta/features/auth/presentation/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator.
final GetIt getIt = GetIt.instance;

/// Registers every dependency by hand — no injectable/build_runner codegen.
///
/// Order follows the dependency graph: async singletons first, then each
/// lazy singleton resolving its collaborators via [getIt].
Future<void> configureDependencies() async {
  // Async singleton resolved up front (SharedPreferences needs getInstance()).
  getIt
    ..registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    )
    ..registerLazySingleton<AppConfig>(AppConfig.new)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<AuthEvents>(
      AuthEvents.new,
      dispose: (events) => events.dispose(),
    )
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()))
    ..registerLazySingleton<ThemeModeController>(
      () => ThemeModeController(getIt()),
    )

    ..registerLazySingleton<Dio>(
      () => buildAppDio(getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<SocialTokenExchange>(
      () => SocialTokenExchange(getIt(), getIt()),
    )
    // First-run flow & 4-role split: the session is the routing source of
    // truth; the router refreshes off it, so both resolve the same singleton.
    ..registerLazySingleton<SessionStore>(
      () => SessionStore(getIt(), getIt()),
    )
    ..registerLazySingleton<SessionController>(
      () => SessionController(getIt(), getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory<AuthCubit>(() => AuthCubit(getIt(), getIt()))
    ..registerLazySingleton<AppRouter>(() => AppRouter(getIt()));
}
