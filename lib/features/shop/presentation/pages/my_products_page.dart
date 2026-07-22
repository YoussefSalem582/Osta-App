import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/models/product.dart';
import 'package:osta/features/shop/presentation/cubit/my_products_cubit.dart';
import 'package:osta/features/shop/presentation/cubit/my_products_state.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// The caller's own shop — owner is resolved server-side, so this one screen
/// serves both the Business store tab and the customer's "my products" push.
class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = MyProductsCubit();
      unawaited(cubit.load());
      return cubit;
    },
    child: const _MyProductsView(),
  );
}

class _MyProductsView extends StatefulWidget {
  const _MyProductsView();

  @override
  State<_MyProductsView> createState() => _MyProductsViewState();
}

class _MyProductsViewState extends State<_MyProductsView> {
  List<Product> _products = [];

  Future<void> _openForm(BuildContext context, {Product? product}) async {
    final saved = await context.push<bool>(
      AppRoutes.productForm,
      extra: product,
    );
    if (saved == true && context.mounted) {
      await context.read<MyProductsCubit>().load();
    }
  }

  Future<void> _onMore(BuildContext context, Product product) async {
    final action = await showModalBottomSheet<_ProductAction>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () => Navigator.of(context).pop(_ProductAction.edit),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(context.l10n.delete),
              onTap: () => Navigator.of(context).pop(_ProductAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case _ProductAction.edit:
        await _openForm(context, product: product);
      case _ProductAction.delete:
        await _confirmDelete(context, product);
      case null:
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deleteProductDialogTitle,
      message: l10n.deleteProductDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<MyProductsCubit>().delete(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyProductsCubit, MyProductsState>(
      listener: (context, state) {
        if (state is MyProductsLoaded) {
          setState(() => _products = state.products);
        } else if (state is MyProductsDeleteSuccess) {
          AppToaster.showMessage(context.l10n.deleteProductSuccess);
          unawaited(context.read<MyProductsCubit>().load());
        } else if (state is MyProductsDeleteError) {
          AppToaster.showError(state.message);
        }
      },
      builder: (context, state) {
        final busy = state is MyProductsDeleteLoading;

        return Stack(
          children: [
            Column(
              children: [
                _Header(onAdd: () => _openForm(context)),
                Expanded(child: _body(context, state)),
              ],
            ),
            if (busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, MyProductsState state) {
    if (state is MyProductsLoading || state is MyProductsInitial) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state is MyProductsError) {
      return ErrorState(
        title: context.l10n.shopErrorTitle,
        message: state.message,
        onRetry: () => context.read<MyProductsCubit>().load(),
      );
    }
    if (_products.isEmpty) {
      return EmptyState(
        icon: Icons.storefront_outlined,
        title: context.l10n.myProductsEmptyTitle,
        message: context.l10n.myProductsEmptyMessage,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ShopProductCard(
          title: product.name,
          price: context.l10n.shopPriceEgp(product.price),
          imageUrl: product.images.isNotEmpty ? product.images.first : null,
          isActive: product.isActive,
          activeText: context.l10n.businessShopBadgeActive,
          pausedText: context.l10n.businessShopBadgePaused,
          onTap: () => context.push(AppRoutes.productDetail, extra: product.id),
          onMoreTap: () => _onMore(context, product),
        );
      },
    );
  }
}

enum _ProductAction { edit, delete }

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (canPop) ...[
            const BackButton(),
            const SizedBox(width: AppSpacing.xs),
          ],
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
                  l10n.myProductsTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (!canPop)
            IconButton(
              tooltip: l10n.shopBrowseMarketplace,
              onPressed: () => context.push(AppRoutes.shopBrowse),
              icon: const Icon(Icons.travel_explore_outlined),
            ),
          InkWell(
            onTap: onAdd,
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
    );
  }
}
