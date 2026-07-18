import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Date/time pickers that show the platform-native control — Cupertino wheel
/// on iOS, the Material dialog everywhere else — mirroring the `.adaptive`
/// convention already used for `SwitchListTile`/`RefreshIndicator` elsewhere
/// in this app.
Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final clampedInitial = initialDate.isBefore(firstDate)
      ? firstDate
      : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return _showCupertinoPickerSheet<DateTime>(
      context: context,
      initialValue: clampedInitial,
      builder: (value, onChanged) => CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: clampedInitial,
        minimumDate: firstDate,
        maximumDate: lastDate,
        onDateTimeChanged: onChanged,
      ),
    );
  }

  return showDatePicker(
    context: context,
    initialDate: clampedInitial,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    final now = DateTime.now();
    final initialDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    );
    return _showCupertinoPickerSheet<TimeOfDay>(
      context: context,
      initialValue: initialTime,
      builder: (value, onChanged) => CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: initialDateTime,
        onDateTimeChanged: (dt) =>
            onChanged(TimeOfDay(hour: dt.hour, minute: dt.minute)),
      ),
    );
  }

  return showTimePicker(context: context, initialTime: initialTime);
}

/// Shared Cupertino modal shell: a Cancel/Done bar over the picker wheel.
/// [T] is only ever `DateTime` or `TimeOfDay` — both immutable value types
/// safe to carry across the `onChanged` closure.
Future<T?> _showCupertinoPickerSheet<T>({
  required BuildContext context,
  required T initialValue,
  required Widget Function(T value, ValueChanged<T> onChanged) builder,
}) {
  var current = initialValue;
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (sheetContext) => Container(
      height: 300,
      color: CupertinoTheme.of(sheetContext).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text(
                  MaterialLocalizations.of(sheetContext).cancelButtonLabel,
                ),
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
              CupertinoButton(
                child: Text(
                  MaterialLocalizations.of(sheetContext).okButtonLabel,
                ),
                onPressed: () => Navigator.of(sheetContext).pop(current),
              ),
            ],
          ),
          Expanded(
            child: builder(current, (value) => current = value),
          ),
        ],
      ),
    ),
  );
}
