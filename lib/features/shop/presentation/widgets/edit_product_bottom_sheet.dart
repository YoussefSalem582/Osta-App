import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class EditProductBottomSheet extends StatefulWidget {
  final Datum product;

  const EditProductBottomSheet({
    super.key,
    required this.product,
  });

  static void show(BuildContext context, Datum product) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => EditProductBottomSheet(product: product),
      ),
    );
  }

  @override
  State<EditProductBottomSheet> createState() => _EditProductBottomSheetState();
}

class _EditProductBottomSheetState extends State<EditProductBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name ?? '');
    _priceController = TextEditingController(
      text: '${widget.product.price ?? 0}',
    );
    _categoryController = TextEditingController(
      text: widget.product.category ?? '',
    );
    _descController = TextEditingController(
      text: widget.product.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
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
              l10n.businessShopEditProductTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.businessShopProductName,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.businessShopProductPrice,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: l10n.businessShopProductCategory,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.businessShopProductDesc,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.product.id == null) return;
                  final price = int.tryParse(_priceController.text) ?? 0;
                  await context.read<ShopCubit>().updateProduct(
                    id: widget.product.id!,
                    name: _nameController.text,
                    price: price,
                    category: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                    description: _descController.text.isNotEmpty
                        ? _descController.text
                        : null,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.businessShopEditProductButton),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
