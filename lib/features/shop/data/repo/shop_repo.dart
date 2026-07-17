import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_provider.dart';
import 'package:osta/features/shop/data/Model/products/products.dart';

class ShopRepo {
  static Future<Products> listProducts() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.products,
    );
    // --------العظيمه اللي  حلت المشكلة-------
    // print(response.statusCode);
    // print(response.data);
    if (response.statusCode == 200) {
      return Products.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  // ----------------------------------------------------------------
}
