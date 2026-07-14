import 'datum.dart';

class ServiseModel {
	bool? success;
	List<Datum>? data;

	ServiseModel({this.success, this.data});

	factory ServiseModel.fromJson(Map<String, dynamic> json) => ServiseModel(
				success: json['success'] as bool?,
				data: (json['data'] as List<dynamic>?)
						?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
						.toList(),
			);

	Map<String, dynamic> toJson() => {
				'success': success,
				'data': data?.map((e) => e.toJson()).toList(),
			};
}
