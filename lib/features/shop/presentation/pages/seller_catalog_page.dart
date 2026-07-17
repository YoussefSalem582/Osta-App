import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shop/presentation/cubit/shop_list_cubit.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_grid.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Route arguments for [SellerCatalogPage], passed as go_router `extra`.
class SellerCatalogArgs extends Equatable {
  const SellerCatalogArgs({
    required this.ownerId,
    required this.isCenter,
    this.ownerName,
  });

  final String ownerId;
  final bool isCenter;
  final String? ownerName;

  @override
  List<Object?> get props => [ownerId, isCenter, ownerName];
}

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
        create: (_) {
          final cubit = ShopListCubit(
            source: ShopSource.seller,
            ownerId: args.ownerId,
            isCenter: args.isCenter,
          );
          unawaited(cubit.load());
          return cubit;
        },
        child: ShopProductGrid(
          emptyMessage: l10n.shopSellerEmptyMessage,
          onTap: (product) =>
              context.push(AppRoutes.productDetail, extra: product.id),
        ),
      ),
    );
  }
}
