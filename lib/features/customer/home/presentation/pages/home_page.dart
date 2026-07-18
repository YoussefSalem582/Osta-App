import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/home/presentation/bloc/home_bloc.dart';
import 'package:osta/features/customer/home/presentation/widgets/active_booking_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/book_service_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_header.dart';
import 'package:osta/features/customer/home/presentation/widgets/nearby_centers_section.dart';
import 'package:osta/features/customer/home/presentation/widgets/shop_section.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/shop/data/models/product.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Customer Home tab content: header, active booking, quick book, nearby
/// centers, and the shop strip. Rendered as index 0 of the customer shell.
///
/// Each section is fed by [HomeBloc], which loads `/me`, `/bookings`,
/// `/centers/nearby` and `/products` concurrently and degrades per-section, so
/// a missing rail (no nearby centers, empty shop) just drops out of the feed.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        HomeBloc(getIt(), getIt(), getIt())..add(const HomeStarted()),
    child: Scaffold(
      // The greeting header replaces the shell's app bar for this tab (the tab
      // is `chromeless`); an AppBar keeps status-bar icon styling correct.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Span the full width (theme default is centerTitle: true, which would
        // cluster the bell + greeting in the middle) so it mirrors correctly
        // in both LTR and RTL.
        centerTitle: false,
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 84,
        title: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (a, b) =>
              a.customerName != b.customerName || a.isLoading != b.isLoading,
          builder: (context, state) => HomeHeader(
            name: state.customerName.isEmpty && state.isLoading
                ? 'Customer name'
                : state.customerName,
          ),
        ),
      ),
      body: const _HomeView(),
    ),
  );
}

/// Stand-in rails shown under the shimmer on first load (never real data — the
/// Skeletonizer paints over them). Ids are empty so the tap guards no-op.
const _skeletonCenters = [
  CenterSummary(
    id: '',
    name: 'Service center',
    rating: 4.5,
    distanceMeters: 1200,
  ),
  CenterSummary(
    id: '',
    name: 'Service center',
    rating: 4.5,
    distanceMeters: 1200,
  ),
  CenterSummary(
    id: '',
    name: 'Service center',
    rating: 4.5,
    distanceMeters: 1200,
  ),
];
const _skeletonProducts = [
  Product(id: '', name: 'Product name', price: 500),
  Product(id: '', name: 'Product name', price: 500),
  Product(id: '', name: 'Product name', price: 500),
];

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final loading = state.isLoading;
        final centers = loading ? _skeletonCenters : state.centers;
        final products = loading ? _skeletonProducts : state.products;
        final nearest = state.centers.isEmpty ? null : state.centers.first;

        return RefreshIndicator.adaptive(
          onRefresh: () async {
            final bloc = context.read<HomeBloc>()..add(const HomeStarted());
            await bloc.stream.firstWhere((s) => !s.isLoading);
          },
          child: Skeletonizer(
            enabled: loading,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              children: [
                if (loading)
                  const _SkeletonHero()
                else if (state.activeBooking != null) ...[
                  ActiveBookingCard(
                    booking: state.activeBooking!,
                    onTap: () => context.push(
                      AppRoutes.bookingStatus,
                      extra: state.activeBooking!.id,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                BookServiceCard(
                  // Always actionable: open the nearest center, or re-request a
                  // fix when there's no location yet.
                  onTap: nearest != null
                      ? () => context.push(
                          AppRoutes.centerDetail,
                          extra: nearest.id,
                        )
                      : () => context.read<HomeBloc>().add(const HomeStarted()),
                ),
                const SizedBox(height: AppSpacing.xl),
                NearbyCentersSection(
                  centers: centers,
                  locationDenied: state.locationDenied,
                  onEnableLocation: () =>
                      context.read<HomeBloc>().add(const HomeStarted()),
                ),
                const SizedBox(height: AppSpacing.xl),
                ShopSection(products: products),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Placeholder block matching the active-booking hero's footprint, shimmered
/// while the feed loads.
class _SkeletonHero extends StatelessWidget {
  const _SkeletonHero();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Container(
      height: 132,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
  );
}
