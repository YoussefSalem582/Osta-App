import 'package:equatable/equatable.dart';
import 'package:osta/features/shop/data/Model/products/pagination.dart';

class Meta extends Equatable {
  const Meta({this.pagination});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );

  final Pagination? pagination;

  Map<String, dynamic> toJson() => {
    'pagination': pagination?.toJson(),
  };

  @override
  List<Object?> get props => [pagination];
}
