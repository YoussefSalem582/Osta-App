part of 'home_bloc.dart';

enum HomeStatus { loading, ready }

/// One flat state: the four sections load together and share a single refresh,
/// so a class-per-section shape would only duplicate the common status.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.customerName = '',
    this.activeBooking,
    this.centers = const [],
    this.products = const [],
    this.locationDenied = false,
  });

  final HomeStatus status;
  final String customerName;
  final Booking? activeBooking;
  final List<CenterSummary> centers;
  final List<Product> products;

  /// The nearby lookup couldn't get a fix (permission/off) — the UI shows an
  /// "enable location" prompt in place of the centers rail.
  final bool locationDenied;

  bool get isLoading => status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    String? customerName,
    Booking? activeBooking,
    List<CenterSummary>? centers,
    List<Product>? products,
    bool? locationDenied,
  }) => HomeState(
    status: status ?? this.status,
    customerName: customerName ?? this.customerName,
    activeBooking: activeBooking ?? this.activeBooking,
    centers: centers ?? this.centers,
    products: products ?? this.products,
    locationDenied: locationDenied ?? this.locationDenied,
  );

  @override
  List<Object?> get props => [
    status,
    customerName,
    activeBooking,
    centers,
    products,
    locationDenied,
  ];
}
