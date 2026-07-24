import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/presentation/map/bloc/map_bloc.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Permission / error / empty, floated over the map rather than replacing it.
class MapStatusOverlay extends StatelessWidget {
  const MapStatusOverlay({required this.state, super.key});

  final MapState state;

  @override
  Widget build(BuildContext context) {
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
        // Min-size Column shrink-wraps the card instead of stretching it over
        // the whole map and blocking pan/zoom.
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
}
