import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class TechScreen extends StatelessWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7DBD4),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  context.l10n.technicians,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mahmoud",
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(0xFF84D3A0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFF2F4F0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF9EABA2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mahmoud",
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(0xFF84D3A0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFF2F4F0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          color: Color(0xFF9EABA2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mahmoud",
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(0xFF84D3A0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Color(0xFFF2F4F0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          color: Color(0xFF9EABA2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              alignment: Alignment.center,

              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brandGreen,style: BorderStyle.solid),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      context.l10n.addTechnician,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.brandGreen,
                        fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
