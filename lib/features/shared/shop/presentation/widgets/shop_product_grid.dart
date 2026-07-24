import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/presentation/bloc/shop_list_bloc.dart';
import 'package:osta/features/shared/shop/presentation/widgets/product_grid_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Paginated 2-column product grid driven by the ambient [ShopListBloc].
/// Owns its own scroll + infinite-scroll trigger, and renders the shared
/// loading / empty / error states. Reused by browse and seller catalog.
class ShopProductGrid extends StatefulWidget {
  const ShopProductGrid({required this.onTap, this.emptyMessage, super.key});

  final void Function(Product product) onTap;
  final String? emptyMessage;

  @override
  State<ShopProductGrid> createState() => _ShopProductGridState();
}

class _ShopProductGridState extends State<ShopProductGrid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context.read<ShopListBloc>().add(const ShopListMoreRequested());
    }
  }

  /// RefreshIndicator needs a future: fire the reload, then wait for the bloc
  /// to leave the loading state so the spinner tracks the real request.
  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<ShopListBloc>()..add(const ShopListStarted());
    return bloc.stream.firstWhere(
      (state) => state.status != ShopListStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ShopListBloc, ShopListState>(
      builder: (context, state) {
        if (state.status == ShopListStatus.loading ||
            state.status == ShopListStatus.initial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.status == ShopListStatus.error) {
          return ErrorState(
            title: l10n.shopErrorTitle,
            message: state.message,
            onRetry: () =>
                context.read<ShopListBloc>().add(const ShopListStarted()),
          );
        }

        if (state.products.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: l10n.shopEmptyTitle,
            message: widget.emptyMessage ?? l10n.shopEmptyMessage,
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductGridCard(
                      product: product,
                      onTap: () => widget.onTap(product),
                    );
                  },
                ),
              ),
              if (state.status == ShopListStatus.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
