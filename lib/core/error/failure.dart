/// Base failure for the domain layer. A native `sealed` class keeps the error
/// model exhaustive without pulling codegen into every error site.
///
/// Implements [Exception] so failures can be thrown and caught with plain
/// try/catch — the beginner-friendly error style used across the app.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error']);
}
