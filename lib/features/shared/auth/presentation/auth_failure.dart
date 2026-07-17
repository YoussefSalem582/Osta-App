import 'package:osta/core/network/api_exception.dart';

/// The presentable shape of an auth failure, mapped once from a thrown
/// exception so the Login / Register / Recovery blocs don't each repeat the
/// same catch chain.
///
/// `networkError` means the request never reached the server; `fieldErrors`
/// are server 422 messages keyed by field (surfaced inline); `message` is a
/// general error string for the toast.
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
