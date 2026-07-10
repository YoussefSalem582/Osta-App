import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({
    required this.text1,
    required this.text2,
    super.key,
  });

  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF636E67),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          text2,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
