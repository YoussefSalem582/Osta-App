import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/shop/data/product_categories.dart';
import 'package:osta/features/shared/shop/presentation/bloc/shop_list_bloc.dart';
import 'package:osta/features/shared/shop/presentation/browse/widgets/category_chips.dart';
import 'package:osta/features/shared/shop/presentation/widgets/shop_product_grid.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_text_field.dart';

/// The two-sided marketplace grid (#48): debounced search + category chips +
/// paginated products from every seller. Used as the customer Store tab and
/// pushed from the business store's "browse marketplace" action.
class ShopBrowsePage extends StatelessWidget {
  const ShopBrowsePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ShopListBloc>()..add(const ShopListStarted()),
    child: const _ShopBrowseView(),
  );
}

class _ShopBrowseView extends StatefulWidget {
  const _ShopBrowseView();

  @override
  State<_ShopBrowseView> createState() => _ShopBrowseViewState();
}

class _ShopBrowseViewState extends State<_ShopBrowseView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<ShopListBloc>().add(
        ShopListSearchChanged(value.trim()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (canPop) ...[
                const BackButton(),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: AppTextField(
                  controller: _searchController,
                  hint: l10n.shopSearchHint,
                  prefixIcon: Icons.search,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                ),
              ),
              IconButton(
                tooltip: l10n.myProductsTitle,
                onPressed: () => context.push(AppRoutes.myProducts),
                icon: const Icon(Icons.storefront_outlined),
              ),
            ],
          ),
        ),
        BlocSelector<ShopListBloc, ShopListState, String?>(
          selector: (state) => state.category,
          builder: (context, selected) => CategoryChips(
            categories: productCategoryKeys,
            selected: selected,
            labelOf: (k) => categoryLabel(l10n, k),
            onSelected: (c) => context.read<ShopListBloc>().add(
              ShopListCategorySelected(c),
            ),
          ),
        ),
        Expanded(
          child: ShopProductGrid(
            onTap: (product) =>
                context.push(AppRoutes.productDetail, extra: product.id),
          ),
        ),
      ],
    );
  }
}
