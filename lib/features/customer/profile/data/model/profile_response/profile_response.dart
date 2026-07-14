import 'package:osta/features/customer/profile/data/model/profile_response/data.dart';

class ProfileResponse {
  bool? success;
  Data? data;

  ProfileResponse({this.success, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
  };
}
