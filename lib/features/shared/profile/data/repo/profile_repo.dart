import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/profile_response.dart';
import 'package:osta/features/shared/profile/data/profile_cache.dart';

/// Profile data source for `GET/PUT /me` + avatar/delete.
///
/// Reads are cache-then-network (the cubit serves [cachedProfile] instantly,
/// then calls [getProfile] to refresh). Writes are online-only and write
/// through to the cache on success so it never goes stale behind a live edit.
class ProfileRepo {
  ProfileRepo(this._api, this._cache);

  final ApiClient _api;
  final ProfileCache _cache;

  /// The locally cached profile for an instant first paint, or `null`.
  Data? get cachedProfile => _cache.read();

  /// When [cachedProfile] was stored, for the "last updated" affordance.
  DateTime? get cachedAt => _cache.fetchedAt;

  /// `GET /me`. Writes through to the cache on success. Unlike before, this
  /// rethrows the typed ApiException (notably NetworkException when offline)
  /// so the cubit can fall back to the cache instead of a blank error.
  Future<ProfileResponse> getProfile() async {
    try {
      final result = await _api.get<Data>(
        ApiEndpoints.me,
        parse: (data) => Data.fromJson(data! as Map<String, dynamic>),
      );
      await _cache.write(result.data, at: DateTime.now());
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.getProfile', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<ProfileResponse?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      final result = await _api.put<Data>(
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
      await _cache.write(result.data, at: DateTime.now());
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.updateProfile', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<ProfileResponse?> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final result = await _api.post<Data>(
        ApiEndpoints.meAvatar,
        body: formData,
        parse: (data) => Data.fromJson(data! as Map<String, dynamic>),
      );
      await _cache.write(result.data, at: DateTime.now());
      return ProfileResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in ProfileRepo.uploadAvatar', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _api.delete<void>(
        ApiEndpoints.me,
        parse: (_) {},
      );
      await _cache.clear();
    } on Object catch (e, s) {
      log('Error in ProfileRepo.deleteAccount', error: e, stackTrace: s);
      rethrow;
    }
  }
}
