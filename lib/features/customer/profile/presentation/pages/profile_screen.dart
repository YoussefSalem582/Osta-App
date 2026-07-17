import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/features/customer/profile/presentation/cubit/profile_cubit.dart';
import 'package:osta/features/customer/profile/presentation/cubit/profile_state.dart';
import 'package:osta/features/customer/profile/presentation/widgets/edit_profile/delete_account_button.dart';
import 'package:osta/features/customer/profile/presentation/widgets/profile/profile_card.dart';
import 'package:osta/features/customer/profile/presentation/widgets/profile/profile_item.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

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
          context.read<SessionController>().signOut();
        } else if (state is ProfileDeleteError) {
          AppToaster.showError(context.l10n.deleteAccountError);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ProfileError) {
            return Center(
              child: Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          } else if (state is ProfileSuccess) {
            final data = state.profile.data;
            if (data == null) {
              return const Center(
                child: Text('No profile data found'),
              );
            }

            final l10n = context.l10n;
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

            final themeController = context.read<ThemeModeController>();
            final sessionController = context.read<SessionController>();

            final isDark =
                context.watch<ThemeModeController>().state == ThemeMode.dark;
            final isArabic =
                context.watch<SessionController>().state.locale?.languageCode ==
                'ar';

            final name = data.fullName ?? '';
            final username = data.username ?? '';
            final supportId = data.supportId ?? '';

            final String formattedSupportId;
            if (supportId.isEmpty) {
              formattedSupportId = '';
            } else if (supportId.toUpperCase().startsWith('OSTA')) {
              formattedSupportId = supportId;
            } else {
              formattedSupportId = 'OSTA-$supportId';
            }

            final userHandle = [
              if (username.isNotEmpty) '@$username',
              if (formattedSupportId.isNotEmpty) formattedSupportId,
            ].join(' · ');

            final firstChar = name.isNotEmpty ? name.characters.first : '؟';

            return ListView(
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
                            child:
                                data.avatarUrl != null &&
                                    data.avatarUrl.toString().isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: data.avatarUrl.toString(),
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) =>
                                          const CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                      errorWidget: (_, _, _) => Text(
                                        firstChar,
                                        style: textTheme.titleLarge?.copyWith(
                                          color: colorScheme.onSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
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
                              name,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              userHandle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppButton(
                        label: l10n.editProfile,
                        onPressed: () async {
                          await context.push(
                            AppRoutes.editProfile,
                            extra: data,
                          );
                          if (!context.mounted) return;
                          await context.read<ProfileCubit>().getProfile();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.surfaceDim.withValues(
                            alpha: 0.4,
                          ),
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
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
                        AppSegmentedToggle(
                          options: [l10n.arabic, l10n.english],
                          selectedIndex: isArabic ? 0 : 1,
                          onSelect: (index) async {
                            await sessionController.chooseLanguage(
                              Locale(index == 0 ? 'ar' : 'en'),
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
                        AppSegmentedToggle(
                          options: [l10n.light, l10n.dark],
                          selectedIndex: isDark ? 1 : 0,
                          onSelect: (index) async {
                            await themeController.setMode(
                              index == 1 ? ThemeMode.dark : ThemeMode.light,
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

                DeleteAccountButton(cubit: context.read<ProfileCubit>()),

                const SizedBox(height: 100),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
