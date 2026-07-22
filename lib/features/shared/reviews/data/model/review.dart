import 'package:equatable/equatable.dart';

/// A single review (mirrors backend `ReviewResource`); same shape across all
/// four review endpoints. Nested `reviewer.name` is flattened to
/// [reviewerName], tolerating null.
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

/// The aggregate rating block for the **center** reviews index
/// (`meta.summary`); the user index has none.
/// ponytail: not currently reachable — `ApiClient` only surfaces
/// `meta.pagination`; wire up when needed.
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
