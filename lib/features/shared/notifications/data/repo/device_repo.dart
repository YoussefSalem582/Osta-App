import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';

/// A registered push device for the authenticated user. Mirrors the backend
/// `DeviceResource` (`DeviceController@store`).
///
/// `platform` is one of `ios` / `android` / `web`; `app` is `b2c` / `b2b`
/// (defaults to `b2c` server-side). Kept as plain strings to match house style
/// — validation lives in the backend `RegisterDeviceRequest` enums.
class Device extends Equatable {
  const Device({
    required this.id,
    required this.token,
    required this.platform,
    required this.app,
    this.lastSeenAt,
    this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id']?.toString() ?? '',
    token: json['token'] as String? ?? '',
    platform: json['platform'] as String? ?? '',
    app: json['app'] as String? ?? 'b2c',
    lastSeenAt: _date(json['last_seen_at']),
    createdAt: _date(json['created_at']),
  );

  final String id;
  final String token;
  final String platform;
  final String app;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  @override
  List<Object?> get props => [id, token, platform, app, lastSeenAt, createdAt];
}

/// Data layer over device (de)registration (`DeviceController`). Static
/// methods; errors bubble up as the typed `ApiException`.
abstract final class DeviceRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  /// Upserts (registers or refreshes) the FCM [token] for this user. [app]
  /// defaults to `b2c` server-side when omitted. HTTP 200 with the device.
  static Future<Device> register({
    required String token,
    required String platform,
    String? app,
  }) async {
    final result = await _api.post<Device>(
      ApiEndpoints.devices,
      body: {
        'token': token,
        'platform': platform,
        'app': ?app,
      },
      parse: (data) => Device.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Revokes the device by its FCM [token]. Idempotent — no 404 if the token
  /// is already gone.
  static Future<void> unregister(String token) => _api.delete<void>(
    ApiEndpoints.device(token),
    parse: (_) {},
  );
}
