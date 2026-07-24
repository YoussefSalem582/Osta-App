import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Discovery filters for the map. Today it holds the single "nearby only"
/// switch; the backend also exposes rating / open-now / price filters, which
/// slot in here as the next rows when wired.
Future<void> showMapFilterSheet(
  BuildContext context, {
  required bool nearbyOnly,
  required ValueChanged<bool> onNearbyOnlyChanged,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.mapFilterTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Local state so the switch animates immediately; the bloc reloads off
        // the same value via the callback.
        _NearbyOnlySwitch(
          initial: nearbyOnly,
          onChanged: onNearbyOnlyChanged,
        ),
      ],
    ),
  ),
);

class _NearbyOnlySwitch extends StatefulWidget {
  const _NearbyOnlySwitch({required this.initial, required this.onChanged});

  final bool initial;
  final ValueChanged<bool> onChanged;

  @override
  State<_NearbyOnlySwitch> createState() => _NearbyOnlySwitchState();
}

class _NearbyOnlySwitchState extends State<_NearbyOnlySwitch> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(context.l10n.mapFilterNearbyOnly),
    subtitle: Text(context.l10n.mapFilterNearbyOnlySubtitle),
    value: _value,
    onChanged: (v) {
      setState(() => _value = v);
      widget.onChanged(v);
    },
  );
}
