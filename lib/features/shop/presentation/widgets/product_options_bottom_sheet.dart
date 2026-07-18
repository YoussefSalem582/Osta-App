import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:osta/features/shop/presentation/widgets/edit_product_bottom_sheet.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ProductOptionsBottomSheet extends StatelessWidget {
  final Datum product;

  const ProductOptionsBottomSheet({
    super.key,
    required this.product,
  });

  static void show(BuildContext context, Datum product) {
    if (product.id == null) return;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => ProductOptionsBottomSheet(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isActive = product.status == 'active';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.businessShopEditProductTitle),
            onTap: () {
              Navigator.pop(context);
              EditProductBottomSheet.show(context, product);
            },
          ),
          ListTile(
            leading: Icon(
              isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
            ),
            title: Text(
              isActive
                  ? l10n.businessShopProductPause
                  : l10n.businessShopProductActivate,
            ),
            onTap: () async {
              Navigator.pop(context);
              await context.read<ShopCubit>().toggleProductStatus(
                id: product.id!,
                isActive: !isActive,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              l10n.businessShopProductDelete,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              await context.read<ShopCubit>().deleteProduct(
                id: product.id!,
              );
            },
          ),
        ],
      ),
    );
  }
}
