import 'package:flutter/material.dart';

class ItemType extends StatelessWidget {
  ItemType({
    required this.text1,
    required this.text2,
    required this.color,
    this.maxLines,
    super.key,
  });

  String text1;
  String text2;
  int? maxLines = 1;
  Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                text1,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                maxLines: maxLines,
                text2,
                style:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF67775A),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
