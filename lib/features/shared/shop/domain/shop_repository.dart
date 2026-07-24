import 'package:osta/core/network/api_client.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';

/// Contract over the polymorphic Shop endpoints; errors bubble up as
/// `ApiException`. Products store image URLs, not files.
abstract interface class ShopRepository {
  /// Browse the whole active catalogue. Optional free-text [query] (name /
  /// description) and [category] filters; [page] is 1-based.
  Future<ApiResult<List<Product>>> browse({
    String? query,
    String? category,
    int page,
    int perPage,
  });

  Future<Product> detail(Object id);

  /// One seller's storefront. The owner is polymorphic, so the endpoint differs
  /// by [isCenter] (ServiceCenter) vs a personal User shop.
  Future<ApiResult<List<Product>>> sellerCatalog({
    required Object ownerId,
    required bool isCenter,
    int page,
    int perPage,
  });

  Future<void> enquire(Object productId, String message);

  // ── My products (owner resolved server-side: business → its center) ──

  Future<ApiResult<List<Product>>> myProducts({int page, int perPage});

  Future<Product> createProduct(Map<String, dynamic> body);

  Future<Product> updateProduct(Object id, Map<String, dynamic> body);

  Future<void> deleteProduct(Object id);

  /// Uploads a device photo (multipart) and returns its public URL to drop into
  /// a product's `images`. There is no per-product binding server-side.
  Future<String> uploadProductImage(String filePath);
}
