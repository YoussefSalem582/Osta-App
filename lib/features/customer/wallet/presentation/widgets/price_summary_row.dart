import 'package:flutter/material.dart';

class PriceSummaryRow extends StatelessWidget {
  const PriceSummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    super.key,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
