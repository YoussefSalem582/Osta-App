import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/profile/presentation/cubit/profile_cubit.dart';
import 'package:osta/features/customer/profile/presentation/cubit/profile_state.dart';
import 'package:osta/features/customer/profile/presentation/widgets/profile/profile_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({required this.cubit, super.key});

  final ProfileCubit cubit;

  Future<void> onTap(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deleteAccountDialogTitle,
      message: l10n.deleteAccountDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true) return;
    await cubit.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: cubit,
      buildWhen: (prev, curr) =>
          curr is ProfileDeleteLoading ||
          curr is ProfileDeleteError ||
          curr is ProfileSuccess ||
          curr is ProfileInitial,
      builder: (context, state) {
        final isDeleting = state is ProfileDeleteLoading;

        return ProfileCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: isDeleting ? null : () => onTap(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: isDeleting
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.error,
                            ),
                          )
                        : Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: colorScheme.error,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.deleteAccount,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
