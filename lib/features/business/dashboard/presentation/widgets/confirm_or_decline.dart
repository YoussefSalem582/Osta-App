import 'package:flutter/material.dart';

class ConfirmOrDecline extends StatelessWidget {
  const ConfirmOrDecline({
    required this.color,
    required this.bgColor,
    required this.text,
    super.key,
  });

  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bgColor),
        onPressed: () {},
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
