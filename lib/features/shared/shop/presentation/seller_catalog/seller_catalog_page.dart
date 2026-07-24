import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/shop/presentation/bloc/shop_list_bloc.dart';
import 'package:osta/features/shared/shop/presentation/seller_catalog/seller_catalog_args.dart';
import 'package:osta/features/shared/shop/presentation/widgets/shop_product_grid.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// One seller's storefront (#48). Reads the polymorphic owner via the center
/// or user storefront endpoint, decided by [SellerCatalogArgs.isCenter].
class SellerCatalogPage extends StatelessWidget {
  const SellerCatalogPage({required this.args, super.key});

  final SellerCatalogArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(title: args.ownerName ?? l10n.shopSellerFallback),
      body: BlocProvider(
        create: (_) =>
            getIt<ShopListBloc>(param1: args)..add(const ShopListStarted()),
        child: ShopProductGrid(
          emptyMessage: l10n.shopSellerEmptyMessage,
          onTap: (product) =>
              context.push(AppRoutes.productDetail, extra: product.id),
        ),
      ),
    );
  }
}
