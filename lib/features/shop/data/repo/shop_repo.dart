import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_provider.dart';
import 'package:osta/features/shop/data/Model/products/products.dart';

class ShopRepo {
  static Future<Products> listProducts() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.products,
    );
    if (response.statusCode == 200) {
      return Products.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  static Future<Products> listMyProducts() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.meProducts,
    );
    if (response.statusCode == 200) {
      return Products.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load my products: ${response.statusCode}');
  }

  static Future<void> addProduct({
    required String name,
    required int price,
    String? description,
    String? category,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'price': price,
    };
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }
    if (category != null && category.isNotEmpty) {
      payload['category'] = category;
    }
    final response = await DioProvider.post(
      endpoint: ApiEndpoints.meProducts,
      data: payload,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product: ${response.statusCode}');
    }
  }

  static Future<void> updateProduct({
    required String id,
    String? name,
    int? price,
    String? description,
    String? category,
    String? status,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null && name.isNotEmpty) payload['name'] = name;
    if (price != null) payload['price'] = price;
    if (description != null) payload['description'] = description;
    if (category != null) payload['category'] = category;
    if (status != null) payload['status'] = status;

    final response = await DioProvider.put(
      endpoint: ApiEndpoints.meProduct(id),
      data: payload,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  static Future<void> toggleProductStatus({
    required String id,
    required bool isActive,
  }) async {
    final response = await DioProvider.put(
      endpoint: ApiEndpoints.meProduct(id),
      data: {
        'status': isActive ? 'active' : 'paused',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to toggle product status: ${response.statusCode}',
      );
    }
  }

  static Future<void> deleteProduct({
    required String id,
  }) async {
    final response = await DioProvider.delete(
      endpoint: ApiEndpoints.meProduct(id),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}
