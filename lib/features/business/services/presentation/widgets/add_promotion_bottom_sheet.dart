import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/presentation/cubit/services_cubit.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class AddPromotionBottomSheet extends StatefulWidget {
  const AddPromotionBottomSheet({super.key});

  static void show(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddPromotionBottomSheet(),
      ),
    );
  }

  @override
  State<AddPromotionBottomSheet> createState() =>
      _AddPromotionBottomSheetState();
}

class _AddPromotionBottomSheetState extends State<AddPromotionBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _discountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.businessServicesAddPromoTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.businessServicesPromoTitleInput,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: l10n.businessServicesPromoSubtitleInput,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.businessServicesPromoDiscount,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final discount = int.tryParse(_discountController.text) ?? 0;

                  await context.read<ServicesCubit>().addPromotion(
                    title: _titleController.text,
                    subtitle: _subtitleController.text,
                    discountPercentage: discount,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.businessServicesAddPromoButton),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
