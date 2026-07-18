import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/presentation/bloc/map_bloc.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_centers_list_sheet.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_filter_sheet.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_recenter_button.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_status_overlay.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_top_controls.dart';
import 'package:osta/features/customer/map/presentation/widgets/place_dialog.dart';
import 'package:osta/shared/extensions/context_ext.dart';

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
        if (state.isBusy) const Center(child: CircularProgressIndicator.adaptive()),
        MapStatusOverlay(state: state),
        MapTopControls(
          searchController: _searchController,
          onSearchChanged: (value) =>
              context.read<MapBloc>().add(SearchChanged(value)),
          filterActive: !state.nearbyOnly,
          onFilterTap: () => _openFilters(context, state),
          selectedCategory: state.category,
          onCategorySelected: (category) =>
              context.read<MapBloc>().add(CategorySelected(category)),
        ),
        MapRecenterButton(onPressed: () => _onRecenter(context, state)),
        if (state.centers.isNotEmpty && !state.isBusy)
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: FloatingActionButton.extended(
                  heroTag: 'map_centers_list',
                  icon: const Icon(Icons.format_list_bulleted),
                  label: Text(
                    context.l10n.mapCentersCount(state.centers.length),
                  ),
                  onPressed: () => _openCentersList(context, state),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  void _openCentersList(BuildContext context, MapState state) {
    final navigator = Navigator.of(context);
    unawaited(
      showCentersListSheet(
        context,
        centers: state.centers,
        onCenterTap: (center) {
          // Close the sheet, then open the profile — same destination a marker
          // tap reaches, so the pushed page owns the stack cleanly.
          navigator.pop();
          unawaited(context.push(AppRoutes.centerDetail, extra: center.id));
        },
      ),
    );
  }

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

  void _onMarkerTap(CenterSummary center) {
    final navigator = Navigator.of(context);
    // Both buttons open the center profile; its Book CTA carries on into the
    // booking-create flow. The sheet closes first so the pushed page owns the
    // stack cleanly.
    void openDetail() {
      navigator.pop();
      unawaited(context.push(AppRoutes.centerDetail, extra: center.id));
    }

    unawaited(
      showPlaceDialog(
        context,
        center: center,
        onBook: openDetail,
        onDetails: openDetail,
      ),
    );
  }

  void _openFilters(BuildContext context, MapState state) {
    final bloc = context.read<MapBloc>();
    unawaited(
      showMapFilterSheet(
        context,
        nearbyOnly: state.nearbyOnly,
        onNearbyOnlyChanged: (value) =>
            bloc.add(NearbyOnlyToggled(value: value)),
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
