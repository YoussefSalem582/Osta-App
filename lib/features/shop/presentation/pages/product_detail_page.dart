import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/models/product.dart';
import 'package:osta/features/shop/data/product_categories.dart';
import 'package:osta/features/shop/presentation/cubit/product_detail_cubit.dart';
import 'package:osta/features/shop/presentation/cubit/product_detail_state.dart';
import 'package:osta/features/shop/presentation/pages/seller_catalog_page.dart';
import 'package:osta/features/shop/presentation/widgets/enquire_sheet.dart';
import 'package:osta/features/shop/presentation/widgets/product_image.dart';
import 'package:osta/features/shop/presentation/widgets/seller_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Product detail (#48): image carousel, price (EGP), description, seller card
/// with view-shop, and the Enquire lead. Fetched fresh by [productId] so the
/// polymorphic owner is always loaded.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = ProductDetailCubit();
      unawaited(cubit.load(productId));
      return cubit;
    },
    child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) => Scaffold(
        appBar: AppTopBar(
          title: switch (state) {
            ProductDetailLoaded(:final product) => product.name,
            _ => context.l10n.shopProductTitle,
          },
        ),
        body: switch (state) {
          ProductDetailLoading() || ProductDetailInitial() => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          ProductDetailError(:final message) => ErrorState(
            title: context.l10n.shopErrorTitle,
            message: message,
            onRetry: () => context.read<ProductDetailCubit>().load(productId),
          ),
          ProductDetailLoaded(:final product) => _Detail(product: product),
        },
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final owner = product.owner;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ImageCarousel(images: product.images),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.shopPriceEgp(product.price),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (product.category != null &&
                        product.category!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Chip(
                        label: Text(categoryLabel(l10n, product.category!)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        product.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (owner != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SellerCard(
                        owner: owner,
                        onTap: owner.id == null
                            ? null
                            : () => context.push(
                                AppRoutes.sellerCatalog,
                                extra: SellerCatalogArgs(
                                  ownerId: owner.id!,
                                  isCenter: owner.isCenter,
                                  ownerName: owner.name,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              label: l10n.shopEnquire,
              icon: Icons.chat_bubble_outline,
              onPressed: () => showEnquireSheet(context, productId: product.id),
            ),
          ),
        ),
      ],
    );
  }
}

/// Swipeable image gallery with page dots — a plain [PageView], no carousel
/// dependency. Falls back to a single placeholder when there are no images.
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final count = images.isEmpty ? 1 : images.length;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, index) => ProductImage(
              url: images.isEmpty ? null : images[index],
            ),
          ),
          if (count > 1)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(count, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
