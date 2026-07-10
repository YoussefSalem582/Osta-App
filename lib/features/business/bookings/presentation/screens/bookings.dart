import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/business/bookings/presentation/widgets/custom_row.dart';
import 'package:osta/features/business/bookings/presentation/widgets/driver_title.dart';
import 'package:osta/features/business/bookings/presentation/widgets/selected_type.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/confirm_or_decline.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class Bookings extends StatelessWidget {
  const Bookings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          const AppBarWidget(),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              SelectedType(
                textColor: Colors.white,
                text: context.l10n.all,
                conColor: Colors.black,
              ),
              const SizedBox(
                width: 8,
              ),
              SelectedType(
                textColor: Colors.black,
                text: context.l10n.waiting,
                conColor: Colors.white,
              ),
              const SizedBox(
                width: 8,
              ),
              SelectedType(
                textColor: Colors.black,

                text: context.l10n.sure,
                conColor: Colors.white,
              ),
              const SizedBox(
                width: 8,
              ),
              SelectedType(
                textColor: Colors.black,
                text: context.l10n.underImplementation,
                conColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const DriverTitle(),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    color: Color(0xFFC4CCC7),
                    endIndent: 8,
                    indent: 8,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomRow(
                    text1: context.l10n.exchangeOilAndFilter,
                    text2: '250 EGP',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomRow(
                    text1: context.l10n.appointment,
                    text2: '12:00 Today',
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      ConfirmOrDecline(
                        color: Colors.white,
                        bgColor: AppColors.brandGreen,
                        text: context.l10n.confirm,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ConfirmOrDecline(
                        color: const Color(0xFFB91D1C),
                        bgColor: const Color(0xFFFEE2E1),
                        text: context.l10n.decline,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.build,
                          size: 18,
                          color: Color(0xFF75856F),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          context.l10n.mechanicalSupport,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF75856F),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
