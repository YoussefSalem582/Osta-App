import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:osta/features/shop/presentation/cubit/shop_state.dart';
import 'package:osta/features/shop/presentation/widgets/add_product_bottom_sheet.dart';
import 'package:osta/features/shop/presentation/widgets/business_shop_header.dart';
import 'package:osta/features/shop/presentation/widgets/edit_product_bottom_sheet.dart';
import 'package:osta/features/shop/presentation/widgets/product_options_bottom_sheet.dart';
import 'package:osta/features/shop/presentation/widgets/shop_content.dart';

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
    return Column(
      children: [
        BusinessShopHeader(
          onAddPressed: () => AddProductBottomSheet.show(context),
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
                return ShopContent(
                  products: state.products,
                  onEditTap: (product) =>
                      EditProductBottomSheet.show(context, product),
                  onMoreTap: (product) =>
                      ProductOptionsBottomSheet.show(context, product),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
