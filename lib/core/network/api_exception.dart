/// Typed exceptions mapped from the backend error envelope
/// (`{success:false, error:{code, message, details}}`), one per `error.code`.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  /// Human-readable message from the backend (or a transport fallback).
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

/// `VALIDATION_ERROR` (422) — carries per-field messages from `error.details`.
class ValidationException extends ApiException {
  const ValidationException(super.message, this.fieldErrors);

  /// Field name → list of validation messages.
  final Map<String, List<String>> fieldErrors;
}

/// `UNAUTHENTICATED` (401).
class UnauthenticatedException extends ApiException {
  const UnauthenticatedException(super.message);
}

/// `FORBIDDEN` (403).
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

/// `NOT_FOUND` (404).
class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

/// `METHOD_NOT_ALLOWED` (405) — the route exists for other verbs but not this
/// one. In practice this means a not-yet-deployed endpoint (e.g. a `GET` added
/// after the server last shipped its `PUT`-only route).
class MethodNotAllowedException extends ApiException {
  const MethodNotAllowedException(super.message);
}

/// `TOO_MANY_REQUESTS` (429).
class RateLimitException extends ApiException {
  const RateLimitException(super.message);
}

/// `SERVER_ERROR` (500) — also the fallback for unknown error codes.
class ServerException extends ApiException {
  const ServerException(super.message);
}

/// Transport-level failure (timeout, DNS, connection refused, …).
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error']);
}

/// Maps a backend error envelope to its typed exception.
ApiException apiExceptionFromEnvelope(Map<String, dynamic> error) {
  final code = error['code'] as String?;
  final message = error['message'] as String? ?? 'Request failed';
  return switch (code) {
    'VALIDATION_ERROR' => ValidationException(message, _fieldErrors(error)),
    'UNAUTHENTICATED' => UnauthenticatedException(message),
    'FORBIDDEN' => ForbiddenException(message),
    'NOT_FOUND' => NotFoundException(message),
    'METHOD_NOT_ALLOWED' => MethodNotAllowedException(message),
    'TOO_MANY_REQUESTS' => RateLimitException(message),
    // SERVER_ERROR and anything unrecognised.
    _ => ServerException(message),
  };
}

Map<String, List<String>> _fieldErrors(Map<String, dynamic> error) {
  final details = error['details'];
  if (details is! Map<String, dynamic>) return const {};
  return details.map(
    (field, messages) => MapEntry(
      field,
      messages is List
          ? messages.map((m) => m.toString()).toList()
          : [messages.toString()],
    ),
  );
}
