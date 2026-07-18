import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';

/// A service on a business owner's service center (B2B). Plain immutable model;
/// hand-written JSON mapping mirrors `Api/B2C/ServiceResource` (`toArray`).
/// Note: this resource does **not** expose `service_center_id`.
///
// ponytail: co-located because the services list/create area (which would own
// `model/service.dart`) isn't built yet; move it there when that lands.
class Service extends Equatable {
  const Service({
    required this.id,
    required this.name,
    required this.price,
    required this.priceType,
    required this.isActive,
    this.description,
    this.category,
    this.durationMinutes,
    this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: _toInt(json['id']),
    name: json['name'] as String? ?? '',
    // Cast `(float)` server-side, but tolerate int/string just in case.
    price: _toDouble(json['price']),
    // Backend enum: "fixed" | "starting_from" | "hourly".
    priceType: json['price_type'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? false,
    description: json['description'] as String?,
    category: json['category'] as String?,
    durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  final int id;
  final String name;
  final double price;

  /// `"fixed"` | `"starting_from"` | `"hourly"`.
  final String priceType;
  final bool isActive;
  final String? description;
  final String? category;
  final int? durationMinutes;
  final DateTime? createdAt;

  static int _toInt(Object? value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static double _toDouble(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s) ?? 0,
    _ => 0,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    priceType,
    isActive,
    description,
    category,
    durationMinutes,
    createdAt,
  ];
}

/// Data layer over the B2B services endpoints. Static methods like the other
/// repos; errors bubble up as the typed `ApiException`. Mirrors
/// `BusinessServiceController` + `Api/B2C/ServiceResource`.
///
/// index/update/delete live here; create is owned by the onboarding repo
/// (`BusinessOnboardingRepository.createCustomService`).
abstract final class BusinessServiceRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Service> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Service.fromJson(e as Map<String, dynamic>))
      .toList();

  static Service _parseOne(Object? data) =>
      Service.fromJson(data! as Map<String, dynamic>);

  /// Every service on the owner's center, or only active/inactive rows when
  /// [active] is set. The owner's single center is resolved server-side, so no
  /// center id is sent. Not paginated (plain array ordered by category, name).
  static Future<List<Service>> index({bool? active}) async {
    final result = await _api.get<List<Service>>(
      ApiEndpoints.businessServices,
      parse: _parseList,
      query: {'active': ?active},
    );
    return result.data;
  }

  /// Adds a service to the owner's center (`POST /business/services`). The
  /// center is resolved server-side. `name`/`price`/`priceType` are required by
  /// the FormRequest; the rest are optional.
  static Future<Service> create({
    required String name,
    required num price,
    required String priceType,
    String? description,
    String? category,
    int? durationMinutes,
    bool isActive = true,
  }) async {
    final result = await _api.post<Service>(
      ApiEndpoints.businessServices,
      parse: _parseOne,
      body: {
        'name': name,
        'price': price,
        'price_type': priceType,
        'description': ?description,
        'category': ?category,
        'duration_minutes': ?durationMinutes,
        'is_active': isActive,
      },
    );
    return result.data;
  }

  /// Partial update — send only the fields being changed. `isActive` toggles
  /// retire/restore. Nullable fields are omitted when null, so this cannot
  /// clear them back to null (matches the other repos).
  static Future<Service> updateService(
    Object id, {
    String? name,
    String? description,
    String? category,
    num? price,
    String? priceType,
    int? durationMinutes,
    bool? isActive,
  }) async {
    final result = await _api.put<Service>(
      ApiEndpoints.businessService(id),
      parse: _parseOne,
      body: {
        'name': ?name,
        'description': ?description,
        'category': ?category,
        'price': ?price,
        'price_type': ?priceType,
        'duration_minutes': ?durationMinutes,
        'is_active': ?isActive,
      },
    );
    return result.data;
  }

  /// Soft-deletes the service (row hidden by default scope, history kept).
  static Future<void> deleteService(Object id) =>
      _api.delete<void>(ApiEndpoints.businessService(id), parse: (_) {});
}
