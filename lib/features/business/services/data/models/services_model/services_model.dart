import 'service_item.dart';

class ServicesModel {
  bool? success;
  List<ServiceItem>? data;

  ServicesModel({this.success, this.data});

  factory ServicesModel.fromJson(Map<String, dynamic> json) => ServicesModel(
    success: json['success'] as bool?,
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}
