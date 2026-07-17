import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
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

  context.read<ShopCubit>().loadInitData();
}

  @override
  Widget build(BuildContext context) {
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
                onTap: () {},
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
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
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
);
        },
      );
    }

    return const SizedBox();
  },
)
        ),
      ],
    );
  }
}
