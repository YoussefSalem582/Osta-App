import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/reviews/data/model/review.dart';

/// Data layer over the four review routes (user/center × index/store), all
/// returning `ReviewResource`. Indexes are server-filtered to visible +
/// approved reviews, newest first.
abstract final class ReviewRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Review> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Review.fromJson(e as Map<String, dynamic>))
      .toList();

  static Review _parseOne(Object? data) =>
      Review.fromJson(data! as Map<String, dynamic>);

  /// Approved reviews for a user's shop, paginated (keep `.meta` for pages).
  static Future<ApiResult<List<Review>>> userReviews(
    Object user, {
    int page = 1,
    int perPage = 15,
  }) => _api.get<List<Review>>(
    ApiEndpoints.userReviews(user),
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  /// Post a review for a user's shop. Comes back `status: "pending"` until
  /// moderated, so it won't appear in [userReviews] at once. May 403 (policy).
  static Future<Review> postUserReview(
    Object user, {
    required int rating,
    String? comment,
  }) async {
    final result = await _api.post<Review>(
      ApiEndpoints.userReviews(user),
      body: {'rating': rating, 'comment': ?comment},
      parse: _parseOne,
    );
    return result.data;
  }

  /// Approved reviews for a service center, paginated. The backend also returns
  /// a `meta.summary` aggregate, but `ApiClient` only surfaces pagination — see
  /// [ReviewSummary].
  static Future<ApiResult<List<Review>>> centerReviews(
    Object center, {
    int page = 1,
    int perPage = 15,
  }) => _api.get<List<Review>>(
    ApiEndpoints.centerReviews(center),
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  /// Post a review for a service center. Comes back `status: "pending"`. May
  /// 404 (inactive center) or 403 (policy).
  static Future<Review> postCenterReview(
    Object center, {
    required int rating,
    String? comment,
  }) async {
    final result = await _api.post<Review>(
      ApiEndpoints.centerReviews(center),
      body: {'rating': rating, 'comment': ?comment},
      parse: _parseOne,
    );
    return result.data;
  }
}
