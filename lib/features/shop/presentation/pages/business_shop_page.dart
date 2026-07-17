import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:osta/features/shop/presentation/cubit/shop_state.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// متجري (منتجات المركز)
class BusinessShopPage extends StatefulWidget {
  const BusinessShopPage({super.key});

  @override
  State<BusinessShopPage> createState() => _BusinessShopPageState();
  static const path = '/business-shop';
}

class _BusinessShopPageState extends State<BusinessShopPage> {
  @override
  void initState() {
    super.initState();
    try {
      unawaited(context.read<ShopCubit>().loadInitData());
    } on Object catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ShopCubit? existingCubit;
    try {
      existingCubit = context.read<ShopCubit>();
    } on Object catch (_) {}

    final content = _buildContent(context);

    if (existingCubit != null) {
      return content;
    }

    return BlocProvider(
      create: (_) {
        final cubit = ShopCubit();
        unawaited(cubit.loadInitData());
        return cubit;
      },
      child: Builder(
        builder: _buildContent,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.businessShopEyebrow,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.businessShopTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showAddProductSheet(context),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ShopCubit, ShopState>(
            builder: (context, state) {
              if (state is ShopLoadedState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is ShopSuccessState) {
                return GridView.builder(
                  itemCount: state.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: .8,
                  ),
                  itemBuilder: (_, index) {
                    final product = state.products[index];

                    return ShopProductCard(
                      title: product.name ?? '',
                      price: '${product.price ?? 0} ج',
                      isActive: product.status == 'active',
                      activeText: l10n.businessShopBadgeActive,
                      pausedText: l10n.businessShopBadgePaused,
                      onTap: () => _showEditProductSheet(context, product),
                      onMoreTap: () =>
                          _showProductOptionsSheet(context, product),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _showAddProductSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final descController = TextEditingController();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة منتج جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final price = int.tryParse(priceController.text) ?? 0;
                        await context.read<ShopCubit>().addProduct(
                          name: nameController.text,
                          price: price,
                          category: categoryController.text.isNotEmpty
                              ? categoryController.text
                              : null,
                          description: descController.text.isNotEmpty
                              ? descController.text
                              : null,
                        );

                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: const Text('إضافة المنتج'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProductSheet(BuildContext context, Datum product) {
    final nameController = TextEditingController(text: product.name ?? '');
    final priceController = TextEditingController(
      text: '${product.price ?? 0}',
    );
    final categoryController = TextEditingController(
      text: product.category ?? '',
    );
    final descController = TextEditingController(
      text: product.description ?? '',
    );

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تعديل المنتج',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (product.id == null) return;
                        final price = int.tryParse(priceController.text) ?? 0;
                        await context.read<ShopCubit>().updateProduct(
                          id: product.id!,
                          name: nameController.text,
                          price: price,
                          category: categoryController.text.isNotEmpty
                              ? categoryController.text
                              : null,
                          description: descController.text.isNotEmpty
                              ? descController.text
                              : null,
                        );

                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: const Text('حفظ التعديلات'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProductOptionsSheet(BuildContext context, Datum product) {
    if (product.id == null) return;
    final isActive = product.status == 'active';

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('تعديل المنتج'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditProductSheet(context, product);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  title: Text(
                    isActive ? 'إيقاف المنتج مؤقتاً' : 'تفعيل المنتج',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await context.read<ShopCubit>().toggleProductStatus(
                      id: product.id!,
                      isActive: !isActive,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'حذف المنتج',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await context.read<ShopCubit>().deleteProduct(
                      id: product.id!,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
