import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shop/data/models/product.dart';

/// Thin data layer over the polymorphic Shop endpoints; errors bubble up as
/// `ApiException`. Products store image URLs, not files.
abstract final class ShopRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Product> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();

  static Product _parseOne(Object? data) =>
      Product.fromJson(data! as Map<String, dynamic>);

  /// Browse the whole active catalogue. Optional free-text [query] (name /
  /// description) and [category] filters; [page] is 1-based.
  static Future<ApiResult<List<Product>>> browse({
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

  static Future<Product> detail(Object id) async {
    final result = await _api.get<Product>(
      ApiEndpoints.product(id),
      parse: _parseOne,
    );
    return result.data;
  }

  /// One seller's storefront. The owner is polymorphic, so the endpoint differs
  /// by [isCenter] (ServiceCenter) vs a personal User shop.
  static Future<ApiResult<List<Product>>> sellerCatalog({
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

  static Future<void> enquire(Object productId, String message) =>
      _api.post<void>(
        ApiEndpoints.productEnquiries(productId),
        body: {'message': message},
        parse: (_) {},
      );

  // ── My products (owner resolved server-side: business → its center) ──

  static Future<ApiResult<List<Product>>> myProducts({
    int page = 1,
    int perPage = 50,
  }) => _api.get<List<Product>>(
    ApiEndpoints.meProducts,
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  static Future<Product> createProduct(Map<String, dynamic> body) async {
    final result = await _api.post<Product>(
      ApiEndpoints.meProducts,
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  static Future<Product> updateProduct(
    Object id,
    Map<String, dynamic> body,
  ) async {
    final result = await _api.put<Product>(
      ApiEndpoints.meProduct(id),
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  static Future<void> deleteProduct(Object id) => _api.delete<void>(
    ApiEndpoints.meProduct(id),
    parse: (_) {},
  );

  /// Uploads a device photo (multipart) and returns its public URL to drop into
  /// a product's `images`. There is no per-product binding server-side.
  static Future<String> uploadProductImage(String filePath) async {
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
