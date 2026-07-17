import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/profile/data/model/profile_response/data.dart';
import 'package:osta/features/customer/profile/data/model/profile_response/profile_response.dart';

class ProfileRepo {
  static Future<ProfileResponse?> getProfile() async {
    try {
      final api = GetIt.instance<ApiClient>();
      final result = await api.get<Data>(
        ApiEndpoints.me,
        parse: (data) => Data.fromJson(data! as Map<String, dynamic>),
      );
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.getProfile', error: e, stackTrace: s);
      return null;
    }
  }

  static Future<ProfileResponse?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      final api = GetIt.instance<ApiClient>();
      final result = await api.put<Data>(
        ApiEndpoints.me,
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'phone': phone,
        },
        parse: (data) => Data.fromJson(data! as Map<String, dynamic>),
      );
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.updateProfile', error: e, stackTrace: s);
      rethrow;
    }
  }

  static Future<ProfileResponse?> uploadAvatar(String filePath) async {
    try {
      final api = GetIt.instance<ApiClient>();
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final result = await api.post<Data>(
        ApiEndpoints.meAvatar,
        body: formData,
        parse: (data) => Data.fromJson(data! as Map<String, dynamic>),
      );
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.uploadAvatar', error: e, stackTrace: s);
      rethrow;
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final api = GetIt.instance<ApiClient>();
      await api.delete<void>(
        ApiEndpoints.me,
        parse: (_) {},
      );
    } on Object catch (e, s) {
      log('Error in ProfileRepo.deleteAccount', error: e, stackTrace: s);
      rethrow;
    }
  }
}
