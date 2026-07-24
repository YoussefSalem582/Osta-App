import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/models/center_detail.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_section_title.dart';

/// "Details" card — street address, phone, WhatsApp and the weekly working
/// hours, each row shown only when the center actually has that field. Renders
/// nothing when it has none of them.
class CenterInfoCard extends StatelessWidget {
  const CenterInfoCard({required this.detail, super.key});

  final CenterDetail detail;

  /// Backend working-hours keys, week order (see [CenterDetail.workingHours]).
  static const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  bool get _hasContact =>
      _notBlank(detail.addressLine) ||
      _notBlank(detail.phone) ||
      _notBlank(detail.whatsapp);

  @override
  Widget build(BuildContext context) {
    final hours = detail.workingHours;
    final hasHours = hours != null && hours.isNotEmpty;
    if (!_hasContact && !hasHours) return const SizedBox.shrink();

    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: l10n.centerDetailDetails),
          const SizedBox(height: AppSpacing.sm),
          if (_notBlank(detail.addressLine))
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: detail.addressLine!,
            ),
          if (_notBlank(detail.phone))
            _InfoRow(icon: Icons.phone_outlined, text: detail.phone!),
          if (_notBlank(detail.whatsapp))
            _InfoRow(icon: Icons.chat_outlined, text: detail.whatsapp!),
          if (hasHours) ...[
            if (_hasContact) const Divider(height: AppSpacing.lg),
            Text(
              l10n.centerDetailHours,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            ..._hoursRows(context, hours),
          ],
        ],
      ),
    );
  }

  List<Widget> _hoursRows(
    BuildContext context,
    Map<String, List<String>> hours,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final todayIndex = DateTime.now().weekday - 1; // 0 = Mon … 6 = Sun.
    // 2024-01-01 is a Monday, so +i walks Mon→Sun for localized day names.
    final monday = DateTime(2024);
    return [
      for (var i = 0; i < _dayKeys.length; i++)
        _hoursRow(
          theme: theme,
          isToday: i == todayIndex,
          day: DateFormat('EEE', locale).format(monday.add(Duration(days: i))),
          value: hours[_dayKeys[i]],
          closed: context.l10n.centerDetailClosed,
        ),
    ];
  }

  Widget _hoursRow({
    required ThemeData theme,
    required bool isToday,
    required String day,
    required List<String>? value,
    required String closed,
  }) {
    final text = (value == null || value.isEmpty)
        ? closed
        : _formatHours(value);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: isToday
          ? AppColors.brandGreen
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(day, style: style)),
          Text(text, style: style),
        ],
      ),
    );
  }

  /// `["09:00","18:00"]` → `09:00 – 18:00`; split shifts join their pairs.
  static String _formatHours(List<String> v) {
    final pairs = <String>[];
    for (var i = 0; i + 1 < v.length; i += 2) {
      pairs.add('${v[i]} – ${v[i + 1]}');
    }
    return pairs.isEmpty ? v.join(' ') : pairs.join('، ');
  }

  static bool _notBlank(String? s) => s != null && s.isNotEmpty;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
