import 'datum.dart';

class GarageResponse {
  bool? success;
  List<Datum>? data;

  GarageResponse({this.success, this.data});

  factory GarageResponse.fromJson(Map<String, dynamic> json) {
    return GarageResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}
