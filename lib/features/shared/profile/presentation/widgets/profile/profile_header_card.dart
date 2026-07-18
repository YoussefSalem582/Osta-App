import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:osta/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_solid_hero_card.dart';

/// Profile screen header: avatar + name/handle + edit button on the brand
/// green hero shell.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({required this.data, super.key});

  final Data data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    return AppSolidHeroCard(
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
                              const CircularProgressIndicator.adaptive(
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
                    color: colorScheme.onPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          AppButton(
            label: l10n.editProfile,
            onPressed: () async {
              await context.push(AppRoutes.editProfile, extra: data);
              if (!context.mounted) return;
              await context.read<ProfileCubit>().getProfile();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.surfaceDim.withValues(alpha: 0.4),
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
    );
  }
}
