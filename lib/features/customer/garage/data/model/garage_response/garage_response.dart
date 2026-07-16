import 'package:osta/features/customer/garage/data/model/garage_response/datum.dart';

class GarageResponse {
  GarageResponse({this.success, this.data});

  factory GarageResponse.fromJson(Map<String, dynamic> json) {
    return GarageResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  bool? success;
  List<Datum>? data;

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}
