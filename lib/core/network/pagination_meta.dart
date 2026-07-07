import 'package:equatable/equatable.dart';

/// Pagination block from the `meta` field of list responses.
///
/// Plain immutable model with hand-written JSON mapping — no codegen. Reused by
/// every list feature (bookings, shop, notifications, …).
class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    currentPage: json['current_page'] as int,
    lastPage: json['last_page'] as int,
    perPage: json['per_page'] as int,
    total: json['total'] as int,
  );

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
