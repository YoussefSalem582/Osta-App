import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/customer/profile/presentation/widgets/profile_card.dart';
import 'package:osta/features/customer/profile/presentation/widgets/profile_item.dart';
import 'package:osta/features/customer/profile/presentation/widgets/segmented_toggle.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final themeController = context.read<ThemeModeController>();
    final sessionController = context.read<SessionController>();

    final isDark = context.watch<ThemeModeController>().state == ThemeMode.dark;
    final isArabic =
        context.watch<SessionController>().state.locale?.languageCode == 'ar';

    const userName = 'أحمد فؤاد';
    const userHandle = '@ahmedfo · OSTA-7F3K9';

    final firstChar = userName.isNotEmpty ? userName.characters.first : '؟';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(centerTitle: false, title: context.l10n.profile),
      body: ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.brandGreen,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.brandLime,
                    child: Text(
                      firstChar,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userHandle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              AppButton(
                label: l10n.editProfile,
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.surfaceDim.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            l10n.account,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: ProfileListItem(
            title: l10n.addresses,
            subtitle: l10n.addressesSubtitle,
            leading: const ProfileItemIcon(
              icon: Icons.location_on_outlined,
              color: Colors.redAccent,
            ),
            onTap: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: ProfileListItem(
            title: l10n.myCars,
            subtitle: l10n.myCarsSubtitle,
            leading: const ProfileItemIcon(
              icon: Icons.directions_car_rounded,
              color: Colors.orange,
            ),
            onTap: () => unawaited(context.push(AppRoutes.garage)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: ProfileListItem(
            title: l10n.myStore,
            subtitle: l10n.myStoreSubtitle,
            leading: const ProfileItemIcon(
              icon: Icons.storefront_outlined,
              color: Colors.purple,
            ),
            onTap: () {},
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            l10n.account,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const ProfileItemIcon(
                  icon: Icons.language_rounded,
                  color: AppColors.brandGreen,
                ),
                Expanded(
                  child: Text(
                    l10n.language,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SegmentedToggle(
                  options: [l10n.arabic, l10n.english],
                  selected: isArabic ? l10n.arabic : l10n.english,
                  onSelect: (val) async {
                    final toArabic = val == l10n.arabic;
                    await sessionController.chooseLanguage(
                      Locale(toArabic ? 'ar' : 'en'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const ProfileItemIcon(
                  icon: Icons.palette_outlined,
                  color: Colors.amber,
                ),
                Expanded(
                  child: Text(
                    l10n.appearance,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SegmentedToggle(
                  options: [l10n.light, l10n.dark],
                  selected: isDark ? l10n.dark : l10n.light,
                  onSelect: (val) async {
                    final toDark = val == l10n.dark;
                    await themeController.setMode(
                      toDark ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ProfileCard(
          child: ProfileListItem(
            title: l10n.notifications,
            subtitle: l10n.notificationsSubtitle,
            leading: const ProfileItemIcon(
              icon: Icons.notifications_outlined,
              color: Colors.blue,
            ),
            onTap: () {},
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    )
    );
  }
}
