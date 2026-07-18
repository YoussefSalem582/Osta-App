import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';

/// Fetches `GET /business/profile` and routes to exactly one outcome —
/// shared by `BusinessProfileScreen` and `BusinessAddressScreen`, which only
/// differ in what they do with the loaded profile (the [onLoaded] prefill).
///
/// `GET /business/profile` isn't deployed everywhere yet (some servers only
/// have PUT), so a 404/405 falls back to [onBlank] — an empty form the owner
/// can still save into via the partial PUT — rather than an error wall.
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
