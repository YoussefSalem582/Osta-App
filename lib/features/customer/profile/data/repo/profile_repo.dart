import 'dart:developer';

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
}
