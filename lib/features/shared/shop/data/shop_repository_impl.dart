import 'package:dio/dio.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  const ShopRepositoryImpl(this._api);

  final ApiClient _api;

  static List<Product> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();

  static Product _parseOne(Object? data) =>
      Product.fromJson(data! as Map<String, dynamic>);

  @override
  Future<ApiResult<List<Product>>> browse({
    String? query,
    String? category,
    int page = 1,
    int perPage = 20,
  }) => _api.get<List<Product>>(
    ApiEndpoints.products,
    parse: _parseList,
    query: {
      'page': page,
      'per_page': perPage,
      if (query != null && query.isNotEmpty) 'q': query,
      if (category != null && category.isNotEmpty) 'category': category,
    },
  );

  @override
  Future<Product> detail(Object id) async {
    final result = await _api.get<Product>(
      ApiEndpoints.product(id),
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<ApiResult<List<Product>>> sellerCatalog({
    required Object ownerId,
    required bool isCenter,
    int page = 1,
    int perPage = 20,
  }) => _api.get<List<Product>>(
    isCenter
        ? ApiEndpoints.centerProducts(ownerId)
        : ApiEndpoints.userProducts(ownerId),
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  @override
  Future<void> enquire(Object productId, String message) => _api.post<void>(
    ApiEndpoints.productEnquiries(productId),
    body: {'message': message},
    parse: (_) {},
  );

  @override
  Future<ApiResult<List<Product>>> myProducts({
    int page = 1,
    int perPage = 50,
  }) => _api.get<List<Product>>(
    ApiEndpoints.meProducts,
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  @override
  Future<Product> createProduct(Map<String, dynamic> body) async {
    final result = await _api.post<Product>(
      ApiEndpoints.meProducts,
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Product> updateProduct(Object id, Map<String, dynamic> body) async {
    final result = await _api.put<Product>(
      ApiEndpoints.meProduct(id),
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<void> deleteProduct(Object id) => _api.delete<void>(
    ApiEndpoints.meProduct(id),
    parse: (_) {},
  );

  @override
  Future<String> uploadProductImage(String filePath) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final result = await _api.post<String>(
      ApiEndpoints.meProductImages,
      body: form,
      parse: (data) => (data! as Map<String, dynamic>)['url'] as String,
    );
    return result.data;
  }
}
