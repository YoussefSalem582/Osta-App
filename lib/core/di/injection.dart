import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/network/dio_provider.dart';
import 'package:osta/core/router/app_router.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository_impl.dart';
import 'package:osta/features/business/onboarding/domain/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';
import 'package:osta/features/customer/booking/data/booking_repository_impl.dart';
import 'package:osta/features/customer/booking/domain/booking_repository.dart';
import 'package:osta/features/customer/booking/presentation/create/bloc/booking_create_bloc.dart';
import 'package:osta/features/customer/booking/presentation/live/bloc/booking_detail_bloc.dart';
import 'package:osta/features/customer/booking/presentation/my_bookings/bloc/bookings_bloc.dart';
import 'package:osta/features/customer/garage/data/garage_repository_impl.dart';
import 'package:osta/features/customer/garage/data/maintenance_repository_impl.dart';
import 'package:osta/features/customer/garage/domain/garage_repository.dart';
import 'package:osta/features/customer/garage/domain/maintenance_repository.dart';
import 'package:osta/features/customer/garage/presentation/garage/cubit/garage_cubit.dart';
import 'package:osta/features/customer/garage/presentation/maintenance/cubit/maintenance_cubit.dart';
import 'package:osta/features/customer/map/data/center_detail_repository_impl.dart';
import 'package:osta/features/customer/map/data/centers_repository_impl.dart';
import 'package:osta/features/customer/map/domain/center_detail_repository.dart';
import 'package:osta/features/customer/map/domain/centers_repository.dart';
import 'package:osta/features/customer/map/presentation/center_detail/bloc/center_detail_bloc.dart';
import 'package:osta/features/customer/map/presentation/map/bloc/map_bloc.dart';
import 'package:osta/features/shared/auth/data/auth_repository_impl.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';
import 'package:osta/features/shared/auth/presentation/login/bloc/login_bloc.dart';
import 'package:osta/features/shared/auth/presentation/password_recovery/bloc/password_recovery_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/profile/data/address_repository_impl.dart';
import 'package:osta/features/shared/profile/data/profile_cache.dart';
import 'package:osta/features/shared/profile/data/profile_repository_impl.dart';
import 'package:osta/features/shared/profile/domain/address_repository.dart';
import 'package:osta/features/shared/profile/domain/profile_repository.dart';
import 'package:osta/features/shared/profile/presentation/addresses/bloc/address_bloc.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:osta/features/shared/shop/data/shop_repository_impl.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';
import 'package:osta/features/shared/shop/presentation/bloc/shop_list_bloc.dart';
import 'package:osta/features/shared/shop/presentation/my_products/bloc/my_products_bloc.dart';
import 'package:osta/features/shared/shop/presentation/product_detail/bloc/product_detail_bloc.dart';
import 'package:osta/features/shared/shop/presentation/seller_catalog/seller_catalog_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator.
final GetIt getIt = GetIt.instance;

/// Registers every dependency by hand, in dependency-graph order.
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
    // Ensure the static DioProvider helpers use the same app-level Dio.
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()));
  // Wire the static DioProvider to the resolved Dio instance.
  DioProvider.dio = getIt<Dio>();
  getIt
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
      () => CentersRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<CenterDetailRepository>(
      () => CenterDetailRepositoryImpl(getIt()),
    )
    // Profile: cache-then-network read-cache on the prefs singleton.
    ..registerLazySingleton<ProfileCache>(() => ProfileCache(getIt()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<AddressRepository>(
      () => AddressRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<LocationService>(
      GeolocatorLocationService.new,
    )
    ..registerLazySingleton<BusinessOnboardingRepository>(
      () => BusinessOnboardingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ShopRepository>(
      () => ShopRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GarageRepository>(
      () => GarageRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<MaintenanceRepository>(
      () => MaintenanceRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory<GarageCubit>(() => GarageCubit(getIt()))
    ..registerFactory<MapBloc>(() => MapBloc(getIt(), getIt()))
    ..registerFactory<BookingsBloc>(() => BookingsBloc(getIt()))
    ..registerFactory<ProfileCubit>(() => ProfileCubit(getIt()))
    ..registerFactory<AddressBloc>(() => AddressBloc(getIt()))
    ..registerFactory<MyProductsBloc>(() => MyProductsBloc(getIt()))
    // Shared by browse and seller catalog: param1 null → the marketplace feed,
    // a SellerCatalogArgs → that seller's storefront.
    ..registerFactoryParam<ShopListBloc, SellerCatalogArgs?, void>(
      (seller, _) => ShopListBloc(getIt(), seller: seller),
    )
    // Per-product bloc: the page passes the product id as param1.
    ..registerFactoryParam<ProductDetailBloc, Object, void>(
      (productId, _) => ProductDetailBloc(getIt(), productId),
    )
    // Per-center funnel bloc: the page passes the center id as param1.
    ..registerFactoryParam<BookingCreateBloc, Object, void>(
      (centerId, _) => BookingCreateBloc(getIt(), getIt(), centerId),
    )
    // Per-booking bloc: the page passes the booking id as param1.
    ..registerFactoryParam<BookingDetailBloc, Object, void>(
      (bookingId, _) => BookingDetailBloc(getIt(), bookingId),
    )
    // Per-center bloc: the page passes the center id as param1.
    ..registerFactoryParam<CenterDetailBloc, Object, void>(
      (centerId, _) => CenterDetailBloc(getIt(), centerId),
    )
    // Per-vehicle cubit: the page passes the vehicle id as param1.
    ..registerFactoryParam<MaintenanceCubit, Object, void>(
      (vehicleId, _) => MaintenanceCubit(getIt(), vehicleId),
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
