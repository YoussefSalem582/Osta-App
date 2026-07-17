import 'pagination.dart';

class Meta {
  Pagination? pagination;

  Meta({this.pagination});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
  };
}
