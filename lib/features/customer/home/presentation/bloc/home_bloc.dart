import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/features/customer/booking/data/models/booking.dart';
import 'package:osta/features/customer/booking/domain/booking_repository.dart';
import 'package:osta/features/customer/map/data/models/center_summary.dart';
import 'package:osta/features/customer/map/domain/centers_repository.dart';
import 'package:osta/features/shared/profile/domain/profile_repository.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads the Home feed from four endpoints concurrently; a failed rail
/// degrades to empty instead of blanking the whole page.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._centers,
    this._location,
    this._profile,
    this._bookings,
    this._shop,
  )
    // Seed the name from cache for an instant header while /me is in flight.
    : super(HomeState(customerName: _profile.cachedProfile?.fullName ?? '')) {
    on<HomeStarted>(_onStarted);
  }

  final CentersRepository _centers;
  final BookingRepository _bookings;
  final ShopRepository _shop;
  final LocationService _location;
  final ProfileRepository _profile;

  /// Non-terminal statuses — the booking still "active" enough to surface on
  /// the home hero card.
  static const _terminal = {
    'completed',
    'cancelled',
    'rejected',
    'expired',
    'no_show',
  };

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    // Start all four before awaiting so they run concurrently.
    final name = _loadName();
    final booking = _loadActiveBooking();
    final centers = _loadCenters();
    final products = _loadProducts();
    final nearby = await centers;
    emit(
      HomeState(
        status: HomeStatus.ready,
        customerName: await name,
        activeBooking: await booking,
        centers: nearby.centers,
        locationDenied: nearby.locationDenied,
        products: await products,
      ),
    );
  }

  Future<String> _loadName() async {
    try {
      final res = await _profile.getProfile();
      return res.data?.fullName ?? _profile.cachedProfile?.fullName ?? '';
    } on Object {
      return _profile.cachedProfile?.fullName ?? '';
    }
  }

  Future<Booking?> _loadActiveBooking() async {
    try {
      final res = await _bookings.list(perPage: 20);
      // The list endpoint doesn't eager-load center/items, so re-fetch the one
      // active booking through show() to get the service + center names.
      Booking? active;
      for (final b in res.data) {
        if (!_terminal.contains(b.status)) {
          active = b;
          break;
        }
      }
      return active == null ? null : await _bookings.show(active.id);
    } on Object {
      return null;
    }
  }

  Future<({List<CenterSummary> centers, bool locationDenied})>
  _loadCenters() async {
    try {
      final pos = await _location.currentPosition();
      final list = await _centers.nearby(lat: pos.lat, lng: pos.lng);
      return (centers: list.take(8).toList(), locationDenied: false);
    } on LocationUnavailable {
      // No fix / permission → the home surfaces an "enable location" prompt
      // instead of a silently empty rail.
      return (centers: const <CenterSummary>[], locationDenied: true);
    } on Object {
      return (centers: const <CenterSummary>[], locationDenied: false);
    }
  }

  Future<List<Product>> _loadProducts() async {
    try {
      final res = await _shop.browse(perPage: 8);
      return res.data;
    } on Object {
      return const [];
    }
  }
}
