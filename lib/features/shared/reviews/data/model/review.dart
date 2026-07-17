import 'package:equatable/equatable.dart';

/// A single review, mirroring the backend `ReviewResource`
/// (`Api/B2C/ReviewResource.php`). The same shape is returned by all four
/// review endpoints (user/center × index/store), so one model covers them.
///
/// The nested `reviewer` object (`{ "name": ... }`, emitted via
/// `whenLoaded('user')`) is flattened to [reviewerName]; it tolerates the
/// object being absent or null.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    required this.status,
    this.comment,
    this.reply,
    this.repliedAt,
    this.reviewerName,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: (json['id'] as num).toInt(),
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? 'pending',
    comment: json['comment'] as String?,
    reply: json['reply'] as String?,
    repliedAt: _date(json['replied_at']),
    reviewerName:
        (json['reviewer'] as Map<String, dynamic>?)?['name'] as String?,
    createdAt: _date(json['created_at']),
  );

  /// Review id.
  final int id;

  /// 1–5.
  final int rating;

  /// `pending` | `approved` | `rejected`. Public indexes only ever return
  /// `approved`; a freshly posted review comes back `pending`.
  final String status;
  final String? comment;

  /// Owner's reply text.
  final String? reply;
  final DateTime? repliedAt;

  /// From `user.full_name`; null when the user has no name.
  final String? reviewerName;
  final DateTime? createdAt;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  List<Object?> get props => [
    id,
    rating,
    status,
    comment,
    reply,
    repliedAt,
    reviewerName,
    createdAt,
  ];
}

/// The aggregate rating block unique to the **center** reviews index
/// (`meta.summary` on `GET /centers/{center}/reviews`). The user index has no
/// summary.
///
/// ponytail: not currently reachable — `ApiClient` only surfaces
/// `meta.pagination` (as `ApiResult.meta`), never `meta.summary`. Kept as the
/// typed value object the contract specifies; wire it up when the client grows
/// a summary channel (an out-of-scope core change).
class ReviewSummary extends Equatable {
  const ReviewSummary({required this.count, this.rating});

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
    // Aggregate average — float or null when there are no ratings yet.
    rating: switch (json['rating']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s),
      _ => null,
    },
    count: (json['count'] as num?)?.toInt() ?? 0,
  );

  /// Aggregate average (float), null when no ratings yet.
  final double? rating;

  /// Total number of ratings counted.
  final int count;

  @override
  List<Object?> get props => [rating, count];
}
