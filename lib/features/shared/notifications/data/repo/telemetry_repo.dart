import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';

/// Data layer over broadcast telemetry
/// (`TelemetryController@broadcastLatency`). The server only logs; the response
/// merely echoes `latency_ms`, so there is nothing worth modelling — the call
/// is fire-and-forget.
abstract final class TelemetryRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  /// Reports client-computed broadcast [latencyMs]
  /// (`receive_time − emitted_at`), validated server-side to the int range
  /// [0, 600000]. Optional [event] / [channel] are logged, not returned.
  static Future<void> reportBroadcastLatency({
    required int latencyMs,
    String? event,
    String? channel,
  }) => _api.post<void>(
    ApiEndpoints.telemetryBroadcastLatency,
    body: {
      'latency_ms': latencyMs,
      'event': ?event,
      'channel': ?channel,
    },
    parse: (_) {},
  );
}
