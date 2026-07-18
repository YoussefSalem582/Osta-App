import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/dashboard/data/repo/dashboard_repo.dart';
import 'package:osta/features/business/onboarding/presentation/business_profile_loader.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/adaptive_pickers.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Monday-first day-key order, matching [BusinessProfile.workingHours]'s
/// 3-letter keys.
const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// 2024-01-01 was a Monday — an anchor so [DateFormat.EEEE] can produce a
/// localized weekday label per day key. Avoids a parallel weekday-name l10n
/// key set purely to re-derive a name `intl` already knows how to localize.
DateTime _dayAnchor(int index) => DateTime(2024, 1, 1 + index);

/// Weekly hours + holidays editor over `GET /business/profile` (prefill) and
/// `PUT /business/capacity` (save). Structural twin of `BusinessAddressScreen`
/// — same load/error/blank-form branches, same save/toast/pop pattern.
///
/// Breaks are a deliberate scope cut: the `breaks` param is simply omitted
/// from the save call, which per `DashboardRepo.updateCapacity`'s
/// null-leaves-unchanged semantics is safe — it will not clear anyone's
/// existing break windows.
class CapacityScreen extends StatefulWidget {
  const CapacityScreen({super.key});

  @override
  State<CapacityScreen> createState() => _CapacityScreenState();
}

class _CapacityScreenState extends State<CapacityScreen> {
  final Map<String, bool> _isOpen = {for (final d in _dayKeys) d: false};
  final Map<String, TimeOfDay?> _openTime = {for (final d in _dayKeys) d: null};
  final Map<String, TimeOfDay?> _closeTime = {
    for (final d in _dayKeys) d: null,
  };
  final List<DateTime> _holidays = [];

  bool _loading = true;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    await loadBusinessProfile(
      logTag: 'CapacityScreen',
      onLoaded: (profile) {
        if (!mounted) return;
        setState(() {
          _prefill(profile);
          _loading = false;
        });
      },
      onBlank: () {
        if (!mounted) return;
        setState(() => _loading = false);
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _loadError = message;
        });
      },
    );
  }

  void _prefill(BusinessProfile p) {
    final hours = p.workingHours;
    for (final day in _dayKeys) {
      final slot = hours?[day];
      final open = slot != null && slot.length == 2;
      _isOpen[day] = open;
      _openTime[day] = open ? _parseTime(slot[0]) : null;
      _closeTime[day] = open ? _parseTime(slot[1]) : null;
    }
    _holidays
      ..clear()
      ..addAll(
        (p.holidays ?? const []).map(DateTime.tryParse).whereType<DateTime>(),
      );
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return (h == null || m == null) ? null : TimeOfDay(hour: h, minute: m);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatTime(TimeOfDay t) => '${_pad(t.hour)}:${_pad(t.minute)}';

  String _formatDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  Future<void> _pickTime(String day, {required bool isOpenField}) async {
    final current = isOpenField ? _openTime[day] : _closeTime[day];
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isOpenField) {
        _openTime[day] = picked;
      } else {
        _closeTime[day] = picked;
      }
    });
  }

  Future<void> _addHoliday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showAdaptiveDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      initialDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _holidays.add(picked));
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final missingTime = _dayKeys.any(
      (day) =>
          _isOpen[day]! && (_openTime[day] == null || _closeTime[day] == null),
    );
    if (missingTime) {
      AppToaster.showError(l10n.businessHoursMissingTimes);
      return;
    }

    setState(() => _saving = true);
    try {
      await DashboardRepo.updateCapacity(
        // The backend validates a present day as exactly 2 items
        // (`slots.*` => size:2) — there is no "closed" shape, so a closed day
        // is represented by omitting its key entirely, not by `[]`. `slots`
        // fully replaces `working_hours` server-side, so an omitted key
        // correctly clears any hours a day previously had.
        slots: {
          for (final day in _dayKeys)
            if (_isOpen[day]!)
              day: [
                _formatTime(_openTime[day]!),
                _formatTime(_closeTime[day]!),
              ],
        },
        holidays: _holidays.map(_formatDate).toList(),
      );
      if (!mounted) return;
      AppToaster.showMessage(l10n.businessHoursSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.businessHoursSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(
        title: l10n.businessHours,
        subtitle: l10n.businessHoursSubtitle,
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_loadError != null) {
      return ErrorState(
        title: l10n.businessHoursErrorTitle,
        message: _loadError,
        onRetry: () => unawaited(_load()),
      );
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _dayKeys.length; i++) _dayRow(context, i),
                const SizedBox(height: AppSpacing.sm),
                _holidaysSection(context),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: l10n.save,
            loading: _saving,
            onPressed: _saving ? null : () => unawaited(_submit()),
          ),
        ),
      ],
    );
  }

  Widget _dayRow(BuildContext context, int index) {
    final l10n = context.l10n;
    final day = _dayKeys[index];
    final isOpen = _isOpen[day]!;
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat.EEEE(locale).format(_dayAnchor(index));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  isOpen
                      ? l10n.businessHoursOpenLabel
                      : l10n.businessHoursClosedLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Switch.adaptive(
                  value: isOpen,
                  onChanged: (v) => setState(() => _isOpen[day] = v),
                ),
              ],
            ),
            if (isOpen)
              Row(
                children: [
                  Expanded(
                    child: _timeField(
                      context,
                      label: l10n.businessHoursOpenTime,
                      value: _openTime[day],
                      onTap: () => unawaited(_pickTime(day, isOpenField: true)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _timeField(
                      context,
                      label: l10n.businessHoursCloseTime,
                      value: _closeTime[day],
                      onTap: () =>
                          unawaited(_pickTime(day, isOpenField: false)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(
    BuildContext context, {
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value == null
              ? context.l10n.businessHoursSelectTime
              : value.format(
                  context,
                ),
        ),
      ),
    );
  }

  Widget _holidaysSection(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.businessHoursHolidaysTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_holidays.isEmpty)
          Text(
            l10n.businessHoursHolidaysEmpty,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final date in _holidays)
                InputChip(
                  label: Text(DateFormat.yMMMd(locale).format(date)),
                  onDeleted: () => setState(() => _holidays.remove(date)),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            label: l10n.businessHoursAddHoliday,
            icon: Icons.add,
            variant: AppButtonVariant.secondary,
            onPressed: () => unawaited(_addHoliday()),
          ),
        ),
      ],
    );
  }
}
