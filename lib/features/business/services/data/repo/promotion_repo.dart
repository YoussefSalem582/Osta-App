import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/services/data/model/promotion.dart';

/// Data layer over the B2B promotions endpoints. Static methods like the other
/// repos; errors bubble up as the typed `ApiException`. Mirrors
/// `BusinessPromotionController` + `PromotionResource` — the owner's single
/// center is resolved server-side, so no center id is sent. The list is **not**
/// paginated (returns a plain array ordered by `starts_at` descending).
abstract final class PromotionRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Promotion> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
      .toList();

  static Promotion _parseOne(Object? data) =>
      Promotion.fromJson(data! as Map<String, dynamic>);

  /// Every promotion, or only active/inactive rows when [active] is set.
  static Future<List<Promotion>> index({bool? active}) async {
    final result = await _api.get<List<Promotion>>(
      ApiEndpoints.businessPromotions,
      parse: _parseList,
      query: {'active': ?active},
    );
    return result.data;
  }

  static Future<Promotion> create({
    required String title,
    required String discountType,
    required num discountValue,
    required DateTime startsAt,
    String? description,
    String? code,
    DateTime? endsAt,
    int? maxRedemptions,
    bool? isActive,
  }) async {
    final result = await _api.post<Promotion>(
      ApiEndpoints.businessPromotions,
      parse: _parseOne,
      body: {
        'title': title,
        'discount_type': discountType,
        'discount_value': discountValue,
        'starts_at': startsAt.toIso8601String(),
        'description': ?description,
        'code': ?code,
        'ends_at': ?endsAt?.toIso8601String(),
        'max_redemptions': ?maxRedemptions,
        'is_active': ?isActive,
      },
    );
    return result.data;
  }

  /// Partial update — send only the fields being changed. Nullable fields
  /// (`description`, `code`, `ends_at`, `max_redemptions`) are omitted when
  /// null, so this cannot clear them back to null (matches the other repos).
  static Future<Promotion> update(
    Object id, {
    String? title,
    String? description,
    String? code,
    String? discountType,
    num? discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    int? maxRedemptions,
    bool? isActive,
  }) async {
    final result = await _api.put<Promotion>(
      ApiEndpoints.businessPromotion(id),
      parse: _parseOne,
      body: {
        'title': ?title,
        'description': ?description,
        'code': ?code,
        'discount_type': ?discountType,
        'discount_value': ?discountValue,
        'starts_at': ?startsAt?.toIso8601String(),
        'ends_at': ?endsAt?.toIso8601String(),
        'max_redemptions': ?maxRedemptions,
        'is_active': ?isActive,
      },
    );
    return result.data;
  }

  /// Hard-deletes the promotion (no soft-delete server-side).
  static Future<void> destroy(Object id) =>
      _api.delete<void>(ApiEndpoints.businessPromotion(id), parse: (_) {});
}
