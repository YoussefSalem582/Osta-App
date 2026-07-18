import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:osta/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:osta/features/shared/profile/presentation/cubit/profile_state.dart';
import 'package:osta/features/shared/profile/presentation/widgets/edit_profile/delete_account_button.dart';
import 'package:osta/features/shared/profile/presentation/widgets/profile/offline_saved_chip.dart';
import 'package:osta/features/shared/profile/presentation/widgets/profile/profile_card.dart';
import 'package:osta/features/shared/profile/presentation/widgets/profile/profile_header_card.dart';
import 'package:osta/features/shared/profile/presentation/widgets/profile/profile_item.dart';
import 'package:osta/features/shared/profile/presentation/widgets/profile/settings_toggle_row.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

final _fakeData = Data(
  fullName: 'Osta User',
  username: 'osta_user',
  supportId: 'OSTA-000000',
);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppTopBar(centerTitle: false, title: context.l10n.profile),
    body: const ProfileView(),
  );
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit();
        unawaited(cubit.getProfile());
        return cubit;
      },
      child: const ProfileViewContent(),
    );
  }
}

class ProfileViewContent extends StatelessWidget {
  const ProfileViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileDeleteSuccess) {
          AppToaster.showMessage(context.l10n.deleteAccountSuccess);
          unawaited(context.read<SessionController>().signOut());
        } else if (state is ProfileDeleteError) {
          AppToaster.showError(context.l10n.deleteAccountError);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileError) {
            return Center(
              child: Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          final isSkeleton = state is ProfileLoading || state is ProfileInitial;
          final success = state is ProfileSuccess ? state : null;
          if (!isSkeleton && success == null) return const SizedBox.shrink();

          if (success != null && success.profile.data == null) {
            return const Center(child: Text('No profile data found'));
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Skeletonizer(
              key: ValueKey(isSkeleton),
              enabled: isSkeleton,
              child: _body(
                context,
                data: success?.profile.data ?? _fakeData,
                fromCache: success?.fromCache ?? false,
                fetchedAt: success?.fetchedAt,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context, {
    required Data data,
    required bool fromCache,
    DateTime? fetchedAt,
  }) {
    final l10n = context.l10n;

    final themeController = context.read<ThemeModeController>();
    final sessionController = context.read<SessionController>();

    final isDark = context.watch<ThemeModeController>().state == ThemeMode.dark;
    final isArabic =
        context.watch<SessionController>().state.locale?.languageCode == 'ar';
    final role = context.watch<SessionController>().state.activeRole;

    return RefreshIndicator.adaptive(
      onRefresh: () => context.read<ProfileCubit>().getProfile(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: [
          if (fromCache) ...[
            OfflineSavedChip(fetchedAt: fetchedAt),
            const SizedBox(height: AppSpacing.sm),
          ],

          ProfileHeaderCard(data: data),

          const SizedBox(height: AppSpacing.lg),

          _accountSectionLabel(context),
          const SizedBox(height: AppSpacing.sm),

          ProfileCard(
            child: ProfileListItem(
              title: role == AppRole.business
                  ? l10n.businessProfileTitle
                  : l10n.addresses,
              subtitle: role == AppRole.business
                  ? l10n.businessProfileSubtitle
                  : l10n.addressesSubtitle,
              leading: ProfileItemIcon(
                icon: role == AppRole.business
                    ? Icons.storefront_outlined
                    : Icons.location_on_outlined,
                color: Colors.redAccent,
              ),
              onTap: () => unawaited(
                context.push(
                  role == AppRole.business
                      ? AppRoutes.businessProfile
                      : AppRoutes.addresses,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (role == AppRole.business) ...[
            ProfileCard(
              child: ProfileListItem(
                title: l10n.businessAddress,
                subtitle: l10n.businessAddressSubtitle,
                leading: const ProfileItemIcon(
                  icon: Icons.location_on_outlined,
                  color: Colors.teal,
                ),
                onTap: () => unawaited(context.push(AppRoutes.businessAddress)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (role == AppRole.customer) ...[
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
          ],

          if (role == AppRole.business)
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

          _accountSectionLabel(context),
          const SizedBox(height: AppSpacing.sm),

          SettingsToggleRow(
            icon: Icons.language_rounded,
            iconColor: AppColors.brandGreen,
            label: l10n.language,
            options: [l10n.arabic, l10n.english],
            selectedIndex: isArabic ? 0 : 1,
            onSelect: (index) async {
              await sessionController.chooseLanguage(
                Locale(index == 0 ? 'ar' : 'en'),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          SettingsToggleRow(
            icon: Icons.palette_outlined,
            iconColor: Colors.amber,
            label: l10n.appearance,
            options: [l10n.light, l10n.dark],
            selectedIndex: isDark ? 1 : 0,
            onSelect: (index) async {
              await themeController.setMode(
                index == 1 ? ThemeMode.dark : ThemeMode.light,
              );
            },
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
              onTap: () => unawaited(context.push(AppRoutes.notifications)),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          DeleteAccountButton(cubit: context.read<ProfileCubit>()),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _accountSectionLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        context.l10n.account,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}