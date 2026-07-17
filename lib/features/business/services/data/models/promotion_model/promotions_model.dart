import 'promotion_item.dart';

class PromotionsModel {
  bool? success;
  List<PromotionItem>? data;

  PromotionsModel({this.success, this.data});

  factory PromotionsModel.fromJson(Map<String, dynamic> json) =>
      PromotionsModel(
        success: json['success'] as bool?,
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => PromotionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}
