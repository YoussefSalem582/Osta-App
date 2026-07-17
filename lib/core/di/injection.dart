import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';
import 'package:osta/features/customer/map/data/repo/centers_repo.dart';
import 'package:osta/features/shared/auth/data/auth_repository_impl.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';
import 'package:osta/features/shared/auth/presentation/login/bloc/login_bloc.dart';
import 'package:osta/features/shared/auth/presentation/password_recovery/bloc/password_recovery_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
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
    // `localeCode` resolves SessionStore lazily (it is registered below, and
    // the closure only runs once a request is in flight), which both breaks the
    // cycle and keeps the header live when the language screen changes it.
    ..registerLazySingleton<Dio>(
      () => buildAppDio(
        getIt(),
        getIt(),
        getIt(),
        localeCode: () => getIt<SessionStore>().localeCode,
      ),
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
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<SessionController>(
      () => SessionController(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<CentersRepository>(
      () => CentersRepository(getIt()),
    )
    ..registerLazySingleton<LocationService>(
      GeolocatorLocationService.new,
    )
    ..registerLazySingleton<BusinessOnboardingRepository>(
      () => BusinessOnboardingRepository(getIt()),
    )
    ..registerFactory<LoginBloc>(() => LoginBloc(getIt(), getIt()))
    ..registerFactory<RegisterBloc>(() => RegisterBloc(getIt(), getIt()))
    ..registerFactory<PasswordRecoveryBloc>(
      () => PasswordRecoveryBloc(getIt()),
    )
    ..registerFactory<BusinessOnboardingCubit>(
      () => BusinessOnboardingCubit(getIt(), getIt()),
    )
    ..registerLazySingleton<AppRouter>(() => AppRouter(getIt()));
}
