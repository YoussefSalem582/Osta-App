// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:osta/core/auth/token_storage.dart' as _i335;
import 'package:osta/core/config/app_config.dart' as _i170;
import 'package:osta/core/network/api_client.dart' as _i559;
import 'package:osta/core/network/auth_events.dart' as _i735;
import 'package:osta/core/network/dio_client.dart' as _i479;
import 'package:osta/core/network/social_token_exchange.dart' as _i527;
import 'package:osta/core/router/app_router.dart' as _i643;
import 'package:osta/core/theme/theme_mode_controller.dart' as _i253;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final preferencesModule = _$PreferencesModule();
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => preferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i170.AppConfig>(() => _i170.AppConfig());
    gh.lazySingleton<_i735.AuthEvents>(
      () => _i735.AuthEvents(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i643.AppRouter>(() => _i643.AppRouter());
    gh.lazySingleton<_i335.TokenStorage>(
      () => _i335.TokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i170.AppConfig>(),
        gh<_i335.TokenStorage>(),
        gh<_i735.AuthEvents>(),
      ),
    );
    gh.lazySingleton<_i253.ThemeModeController>(
      () => _i253.ThemeModeController(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i559.ApiClient>(() => _i559.ApiClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i527.SocialTokenExchange>(
      () => _i527.SocialTokenExchange(
        gh<_i559.ApiClient>(),
        gh<_i335.TokenStorage>(),
      ),
    );
    return this;
  }
}

class _$PreferencesModule extends _i253.PreferencesModule {}

class _$StorageModule extends _i335.StorageModule {}

class _$NetworkModule extends _i479.NetworkModule {}
