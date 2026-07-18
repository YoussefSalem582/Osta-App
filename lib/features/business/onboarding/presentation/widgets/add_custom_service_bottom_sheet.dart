import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/catalog_cubit.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';

class AddCustomServiceBottomSheet extends StatefulWidget {
  const AddCustomServiceBottomSheet({super.key});

  static void show(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const AddCustomServiceBottomSheet(),
        ),
      ),
    );
  }

  @override
  State<AddCustomServiceBottomSheet> createState() =>
      _AddCustomServiceBottomSheetState();
}

class _AddCustomServiceBottomSheetState
    extends State<AddCustomServiceBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
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
              l10n.businessCatalogAddCustomService,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.businessServicesServiceName,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.businessServicesServicePrice,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.businessServicesServiceDuration,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.businessServicesAddServiceButton,
                loading: _isLoading,
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    setState(() => _isLoading = true);
                    final price = int.tryParse(_priceController.text) ?? 0;
                    final duration =
                        int.tryParse(_durationController.text) ?? 0;

                    await context.read<CatalogCubit>().addCustomService(
                      name: _nameController.text,
                      price: price,
                      duration: duration,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
