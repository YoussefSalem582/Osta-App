import 'package:flutter/material.dart';

/// A bold `titleMedium` heading for a page section (e.g. "Services",
/// "Reviews"). The label every detail/create screen was hand-rolling as a
/// private `_SectionTitle`.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}
