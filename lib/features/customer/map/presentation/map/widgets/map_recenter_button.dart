import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Floating "my location" button, bottom-end over the map.
class MapRecenterButton extends StatelessWidget {
  const MapRecenterButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FloatingActionButton.small(
          heroTag: 'map_recenter',
          tooltip: context.l10n.mapRecenter,
          onPressed: onPressed,
          child: const Icon(Icons.my_location),
        ),
      ),
    ),
  );
}
