import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';

const _oil = CatalogPreset(
  id: 'p1',
  category: 'oil',
  name: 'Oil Change',
  defaultPrice: 350,
  defaultDurationMinutes: 30,
  categoryLabel: 'Oils',
);

const _brakes = CatalogPreset(
  id: 'p2',
  category: 'brakes',
  name: 'Brake Pads',
  defaultPrice: 250,
  defaultDurationMinutes: 60,
);

class _FakeRepo implements BusinessOnboardingRepository {
  _FakeRepo({
    this.profileError,
    this.catalogError,
    this.presetsError,
  });

  final List<CatalogPreset> presets = const [_oil, _brakes];
  final Exception? profileError;
  final Exception? catalogError;
  final Exception? presetsError;

  BusinessProfileInput? lastProfile;
  List<String>? lastCatalogIds;
  int attachCalls = 0;

  @override
  Future<void> updateProfile(BusinessProfileInput input) async {
    lastProfile = input;
    if (profileError != null) throw profileError!;
  }

  @override
  Future<List<CatalogPreset>> fetchPresets() async {
    if (presetsError != null) throw presetsError!;
    return presets;
  }

  @override
  Future<void> attachCatalog(List<String> presetIds) async {
    attachCalls++;
    lastCatalogIds = presetIds;
    if (catalogError != null) throw catalogError!;
  }
}

void main() {
  group('BusinessOnboardingCubit', () {
    test('loadPresets populates and pre-selects all', () async {
      final cubit = BusinessOnboardingCubit(_FakeRepo());
      await cubit.loadPresets();

      expect(cubit.state.presets, hasLength(2));
      expect(cubit.state.selectedPresetIds, {_oil.id, _brakes.id});
      expect(cubit.state.status, BusinessOnboardingStatus.idle);
      await cubit.close();
    });

    test('togglePreset selects and deselects', () async {
      final cubit = BusinessOnboardingCubit(_FakeRepo());
      await cubit.loadPresets();

      cubit.togglePreset(_oil.id);
      expect(cubit.state.selectedPresetIds.contains(_oil.id), isFalse);
      cubit.togglePreset(_oil.id);
      expect(cubit.state.selectedPresetIds.contains(_oil.id), isTrue);
      await cubit.close();
    });

    test('activate is a no-op when nothing is selected', () async {
      final repo = _FakeRepo();
      final cubit = BusinessOnboardingCubit(repo);
      await cubit.loadPresets();
      cubit
        ..togglePreset(_oil.id)
        ..togglePreset(_brakes.id);

      await cubit.activate();
      expect(repo.attachCalls, 0);
      expect(cubit.state.status, isNot(BusinessOnboardingStatus.activated));
      await cubit.close();
    });

    test('activate posts selected ids and emits activated', () async {
      final repo = _FakeRepo();
      final cubit = BusinessOnboardingCubit(repo);
      await cubit.loadPresets();
      cubit.togglePreset(_brakes.id); // leave only oil selected

      await cubit.activate();
      expect(repo.attachCalls, 1);
      expect(repo.lastCatalogIds, [_oil.id]);
      expect(cubit.state.status, BusinessOnboardingStatus.activated);
      await cubit.close();
    });

    test('submitProfile maps 422 field errors', () async {
      final repo = _FakeRepo(
        profileError: const ValidationException('bad', {
          'phone': ['Invalid phone'],
        }),
      );
      final cubit = BusinessOnboardingCubit(repo)
        ..updateTradeName('Cairo Motors')
        ..updatePhone('1012345678')
        ..setLocation((lat: 30.0, lng: 31.0));

      await cubit.submitProfile();
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      expect(cubit.state.fieldErrors['phone']?.first, 'Invalid phone');
      await cubit.close();
    });

    test('submitProfile normalizes phone and sends profile', () async {
      final repo = _FakeRepo();
      final cubit = BusinessOnboardingCubit(repo)
        ..updateTradeName('Cairo Motors')
        ..updatePhone('01012345678')
        ..setLocation((lat: 30.04, lng: 31.23));

      await cubit.submitProfile();
      expect(cubit.state.status, BusinessOnboardingStatus.profileSubmitted);
      expect(repo.lastProfile?.tradeName, 'Cairo Motors');
      expect(repo.lastProfile?.phone, '+201012345678');
      expect(repo.lastProfile?.latitude, 30.04);
      await cubit.close();
    });

    test('category filter narrows filteredPresets', () async {
      final cubit = BusinessOnboardingCubit(_FakeRepo());
      await cubit.loadPresets();
      cubit.setCategoryFilter('oil');
      expect(cubit.state.filteredPresets, [_oil]);
      await cubit.close();
    });

    test('loadPresets surfaces network errors', () async {
      final cubit = BusinessOnboardingCubit(
        _FakeRepo(presetsError: const NetworkException()),
      );
      await cubit.loadPresets();
      expect(cubit.state.networkError, isTrue);
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      await cubit.close();
    });

    test('activate surfaces catalog validation errors', () async {
      final cubit = BusinessOnboardingCubit(
        _FakeRepo(
          catalogError: const ValidationException('empty', {
            'items': ['At least one service is required'],
          }),
        ),
      );
      await cubit.loadPresets();
      await cubit.activate();
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      expect(cubit.state.fieldErrors['items']?.first, contains('required'));
      await cubit.close();
    });
  });
}
