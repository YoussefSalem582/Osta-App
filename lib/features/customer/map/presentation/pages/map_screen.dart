import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/location_service.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/presentation/bloc/map_bloc.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_category_chips.dart';
import 'package:osta/features/customer/map/presentation/widgets/place_dialog.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Full-screen discovery map, shown by the customer shell's center FAB.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MapBloc(getIt(), getIt())..add(const MapStarted()),
    child: const _MapView(),
  );
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  /// Downtown Cairo — what the camera shows for the beat before the GPS fix
  /// lands, and where it stays if the user refuses location.
  static const _fallbackTarget = LatLng(30.0444, 31.2357);
  static const _zoom = 13.0;

  final _searchController = TextEditingController();
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<MapBloc, MapState>(
    // Only a new fix moves the camera; marker refreshes must not yank it back.
    listenWhen: (previous, current) => previous.position != current.position,
    listener: (context, state) => unawaited(_moveCamera(state.position)),
    builder: (context, state) => Stack(
      children: [
        _buildMap(state),
        if (state.isBusy) const Center(child: CircularProgressIndicator()),
        _buildStatusOverlay(context, state),
        _buildTopControls(context, state),
        _buildRecenterButton(context, state),
      ],
    ),
  );

  Widget _buildMap(MapState state) {
    final position = state.position;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: position == null
            ? _fallbackTarget
            : LatLng(position.lat, position.lng),
        zoom: _zoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        // The fix usually lands before the controller does, and that camera
        // move is one-shot — without this the map sticks on the fallback.
        unawaited(_moveCamera(context.read<MapBloc>().state.position));
      },
      myLocationEnabled: state.position != null,
      // Replaced by the branded recenter button.
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _markers(state),
    );
  }

  Set<Marker> _markers(MapState state) => {
    for (final (index, center) in state.centers.indexed)
      if (center.hasPosition)
        Marker(
          // Centers with no id would all collapse to MarkerId('') and the
          // plugin would silently drop every duplicate but one.
          markerId: MarkerId(center.id.isEmpty ? 'center_$index' : center.id),
          position: LatLng(center.latitude!, center.longitude!),
          // ponytail: default pin. The mockup's price-pill markers need a
          // Canvas-rendered BitmapDescriptor (CenterSummary.price is already
          // parsed for it) — polish, not an acceptance criterion.
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () => _onMarkerTap(center),
        ),
  };

  Widget _buildTopControls(BuildContext context, MapState state) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: AppTextField(
              controller: _searchController,
              label: context.l10n.mapSearchHint,
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  context.read<MapBloc>().add(SearchChanged(value)),
            ),
          ),
        ),
        MapCategoryChips(
          selected: state.category,
          onSelected: (category) =>
              context.read<MapBloc>().add(CategorySelected(category)),
        ),
      ],
    ),
  );

  Widget _buildRecenterButton(BuildContext context, MapState state) => SafeArea(
    child: Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FloatingActionButton.small(
          heroTag: 'map_recenter',
          tooltip: context.l10n.mapRecenter,
          onPressed: () => _onRecenter(context, state),
          child: const Icon(Icons.my_location),
        ),
      ),
    ),
  );

  /// Permission / error / empty, floated over the map rather than replacing it.
  Widget _buildStatusOverlay(BuildContext context, MapState state) {
    final overlay = switch (state.status) {
      MapStatus.locationDenied => _permissionState(context, state),
      MapStatus.error => ErrorState(
        title: context.l10n.mapErrorTitle,
        message: _errorMessage(context, state.error),
        onRetry: () => context.read<MapBloc>().add(const RetryRequested()),
      ),
      _ when state.isEmpty => EmptyState(
        title: context.l10n.mapEmptyTitle,
        message: context.l10n.mapEmptyBody,
        icon: Icons.location_off_outlined,
      ),
      _ => null,
    };
    if (overlay == null) return const SizedBox.shrink();
    return Center(
      child: Padding(
        // Clear of the search bar and chips above.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl * 3,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        // EmptyState/ErrorState centre themselves into whatever they are given,
        // which is correct as a Scaffold body but here would stretch the card
        // over the whole map and swallow every pan/zoom. The min-size Column
        // hands them an unbounded height so they shrink-wrap instead.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AppCard(child: overlay)],
        ),
      ),
    );
  }

  /// "Denied forever" can only be undone in OS settings, so that case swaps the
  /// button rather than asking again in a loop.
  Widget _permissionState(BuildContext context, MapState state) {
    final l10n = context.l10n;
    final bloc = context.read<MapBloc>();
    final deniedForever =
        state.denial == LocationDenial.permissionDeniedForever;
    final serviceDisabled = state.denial == LocationDenial.serviceDisabled;
    return ErrorState(
      title: serviceDisabled
          ? l10n.mapLocationDisabledTitle
          : l10n.mapPermissionTitle,
      message: serviceDisabled
          ? l10n.mapLocationDisabledBody
          : l10n.mapPermissionBody,
      retryLabel: deniedForever
          ? l10n.mapPermissionSettings
          : l10n.mapPermissionGrant,
      onRetry: () => deniedForever
          ? unawaited(bloc.openLocationSettings())
          : bloc.add(const MapStarted()),
    );
  }

  String _errorMessage(BuildContext context, Object? error) => switch (error) {
    NetworkException() => context.l10n.errorNetwork,
    ApiException(:final message) => message,
    // Not a network/API failure (e.g. a client-side parse bug) — saying
    // "can't reach the server" here would be false; the request succeeded.
    _ => context.l10n.errorGeneric,
  };

  void _onMarkerTap(CenterSummary center) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    // Booking funnel (app #44) and the center profile (app #42) have no route
    // yet — same coming-soon surface the shell already uses. The sheet has to
    // close first or the toast renders behind it and the buttons look dead.
    void comingSoon() {
      navigator.pop();
      AppToaster.showMessage(l10n.comingSoonBody);
    }

    unawaited(
      showPlaceDialog(
        context,
        center: center,
        onBook: comingSoon,
        onDetails: comingSoon,
      ),
    );
  }

  void _onRecenter(BuildContext context, MapState state) {
    if (state.position == null) {
      // Never got a fix — recenter means "ask again".
      context.read<MapBloc>().add(const MapStarted());
      return;
    }
    unawaited(_moveCamera(state.position));
  }

  Future<void> _moveCamera(GeoPoint? position) async {
    final controller = _mapController;
    if (controller == null || position == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.lat, position.lng), _zoom),
    );
  }
}
