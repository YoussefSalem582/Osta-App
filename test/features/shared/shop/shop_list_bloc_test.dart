import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';
import 'package:osta/features/shared/shop/presentation/bloc/shop_list_bloc.dart';
import 'package:osta/features/shared/shop/presentation/seller_catalog/seller_catalog_args.dart';

/// The pagination cursor and the browse-vs-seller split used to live behind a
/// static repo, so none of it could be tested. Now that the bloc takes the
/// contract, these pin the parts that silently corrupt the grid when wrong.
class _FakeShopRepository implements ShopRepository {
  final browseCalls = <({String? query, String? category, int page})>[];
  final sellerCalls = <({Object ownerId, bool isCenter, int page})>[];

  /// Products returned per page, and the meta that decides `hasMore`.
  int lastPage = 1;
  ApiException? error;

  @override
  Future<ApiResult<List<Product>>> browse({
    String? query,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    browseCalls.add((query: query, category: category, page: page));
    return _result(page, 'browse');
  }

  @override
  Future<ApiResult<List<Product>>> sellerCatalog({
    required Object ownerId,
    required bool isCenter,
    int page = 1,
    int perPage = 20,
  }) async {
    sellerCalls.add((ownerId: ownerId, isCenter: isCenter, page: page));
    return _result(page, 'seller');
  }

  ApiResult<List<Product>> _result(int page, String tag) {
    final failure = error;
    if (failure != null) throw failure;
    return ApiResult(
      [Product(id: '$tag-$page', name: '$tag page $page', price: 10)],
      meta: PaginationMeta(
        currentPage: page,
        lastPage: lastPage,
        perPage: 20,
        total: lastPage,
      ),
    );
  }

  @override
  Future<Product> detail(Object id) => throw UnimplementedError();

  @override
  Future<void> enquire(Object productId, String message) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<Product>>> myProducts({
    int page = 1,
    int perPage = 50,
  }) => throw UnimplementedError();

  @override
  Future<Product> createProduct(Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<Product> updateProduct(Object id, Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<void> deleteProduct(Object id) => throw UnimplementedError();

  @override
  Future<String> uploadProductImage(String filePath) =>
      throw UnimplementedError();
}

/// Settles the bloc's event queue.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('ShopListBloc', () {
    test('a null seller reads the marketplace feed', () async {
      final repo = _FakeShopRepository();
      final bloc = ShopListBloc(repo)..add(const ShopListStarted());
      await _settle();

      expect(repo.browseCalls, hasLength(1));
      expect(repo.sellerCalls, isEmpty);
      expect(bloc.state.status, ShopListStatus.loaded);
      expect(bloc.state.products, hasLength(1));
      await bloc.close();
    });

    test('a seller reads that storefront, carrying isCenter', () async {
      final repo = _FakeShopRepository();
      final bloc = ShopListBloc(
        repo,
        seller: const SellerCatalogArgs(ownerId: 'c1', isCenter: true),
      )..add(const ShopListStarted());
      await _settle();

      expect(repo.browseCalls, isEmpty);
      expect(repo.sellerCalls.single.ownerId, 'c1');
      expect(repo.sellerCalls.single.isCenter, isTrue);
      await bloc.close();
    });

    test('load-more appends the next page instead of replacing', () async {
      final repo = _FakeShopRepository()..lastPage = 2;
      final bloc = ShopListBloc(repo)..add(const ShopListStarted());
      await _settle();

      bloc.add(const ShopListMoreRequested());
      await _settle();

      expect(repo.browseCalls.map((c) => c.page), [1, 2]);
      expect(bloc.state.products.map((p) => p.id), [
        'browse-1',
        'browse-2',
      ]);
      expect(bloc.state.page, 2);
      expect(bloc.state.hasMore, isFalse);
      await bloc.close();
    });

    test('load-more is a no-op once the last page is loaded', () async {
      final repo = _FakeShopRepository();
      final bloc = ShopListBloc(repo)..add(const ShopListStarted());
      await _settle();

      bloc.add(const ShopListMoreRequested());
      await _settle();

      expect(repo.browseCalls, hasLength(1));
      await bloc.close();
    });

    test('search resets to page 1 and passes the term', () async {
      final repo = _FakeShopRepository()..lastPage = 3;
      final bloc = ShopListBloc(repo)..add(const ShopListStarted());
      await _settle();
      bloc.add(const ShopListMoreRequested());
      await _settle();

      bloc.add(const ShopListSearchChanged('oil'));
      await _settle();

      expect(repo.browseCalls.last.page, 1);
      expect(repo.browseCalls.last.query, 'oil');
      expect(bloc.state.page, 1);
      expect(bloc.state.products.map((p) => p.id), ['browse-1']);
      await bloc.close();
    });

    test('a failed load-more keeps the loaded list usable', () async {
      final repo = _FakeShopRepository()..lastPage = 2;
      final bloc = ShopListBloc(repo)..add(const ShopListStarted());
      await _settle();

      repo.error = const NetworkException('down');
      bloc.add(const ShopListMoreRequested());
      await _settle();

      expect(bloc.state.status, ShopListStatus.loaded);
      expect(bloc.state.products, hasLength(1));
      expect(bloc.state.message, 'down');
      await bloc.close();
    });
  });
}
