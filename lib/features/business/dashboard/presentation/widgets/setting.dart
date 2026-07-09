import 'package:flutter/material.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class Setting extends StatelessWidget {
  Setting({required this.icon, required this.text, super.key});

  IconData icon;
  String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: 24,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Color(0xFFE9F7EE),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon,size: 16,),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFA6B5AC),
            ),
          ],
        ),
      ),
    );
  }
}
