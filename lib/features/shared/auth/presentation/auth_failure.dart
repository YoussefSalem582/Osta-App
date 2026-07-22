import 'package:osta/core/network/api_exception.dart';

/// Presentable shape of an auth failure, mapped once so blocs share one catch
/// chain. `networkError`: request never reached server; `fieldErrors`: server
/// 422s keyed by field; `message`: general text for the toast.
typedef AuthFailure = ({
  String? message,
  Map<String, List<String>> fieldErrors,
  bool networkError,
});

/// Maps a thrown [Object] to the [AuthFailure] a bloc emits. Mirrors the old
/// cubit `_run` catch order: validation → network → generic API → unknown.
AuthFailure mapAuthFailure(Object error) => switch (error) {
  ValidationException(:final message, :final fieldErrors) => (
    message: message,
    fieldErrors: fieldErrors,
    networkError: false,
  ),
  NetworkException() => (
    message: null,
    fieldErrors: const {},
    networkError: true,
  ),
  ApiException(:final message) => (
    message: message,
    fieldErrors: const {},
    networkError: false,
  ),
  _ => (message: null, fieldErrors: const {}, networkError: false),
};
