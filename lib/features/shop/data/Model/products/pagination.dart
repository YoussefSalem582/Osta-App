class Pagination {
  int? total;
  int? count;
  int? perPage;
  int? currentPage;
  int? lastPage;

  Pagination({
    this.total,
    this.count,
    this.perPage,
    this.currentPage,
    this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int?,
    count: json['count'] as int?,
    perPage: json['per_page'] as int?,
    currentPage: json['current_page'] as int?,
    lastPage: json['last_page'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'count': count,
    'per_page': perPage,
    'current_page': currentPage,
    'last_page': lastPage,
  };
}
