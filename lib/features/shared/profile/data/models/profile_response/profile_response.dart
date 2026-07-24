import 'package:osta/features/shared/profile/data/models/profile_response/data.dart';

class ProfileResponse {
  ProfileResponse({this.success, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
  bool? success;
  Data? data;

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
  };
}
