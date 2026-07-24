import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/domain/business_onboarding_repository.dart';

/// Fetches `GET /business/profile`; falls back to [onBlank] on 404/405 since
/// the endpoint isn't deployed everywhere yet.
Future<void> loadBusinessProfile({
  required String logTag,
  required ValueChanged<BusinessProfile> onLoaded,
  required VoidCallback onBlank,
  required ValueChanged<String> onError,
}) async {
  try {
    final profile = await GetIt.instance<BusinessOnboardingRepository>()
        .fetchProfile();
    onLoaded(profile);
  } on NotFoundException catch (_) {
    onBlank();
  } on MethodNotAllowedException catch (_) {
    onBlank();
  } on ApiException catch (e) {
    onError(e.message);
  } on Object catch (e, s) {
    log('$logTag.load failed', error: e, stackTrace: s);
    onError(e.toString());
  }
}
