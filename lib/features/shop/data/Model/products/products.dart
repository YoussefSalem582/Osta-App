import 'package:equatable/equatable.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/data/Model/products/meta.dart';

class Products extends Equatable {
  const Products({this.success, this.data, this.meta});

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    success: json['success'] as bool?,
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
        .toList(),
    meta: json['meta'] == null
        ? null
        : Meta.fromJson(json['meta'] as Map<String, dynamic>),
  );

  final bool? success;
  final List<Datum>? data;
  final Meta? meta;

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
    'meta': meta?.toJson(),
  };

  @override
  List<Object?> get props => [success, data, meta];
}
