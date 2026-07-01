import 'package:fpdart/fpdart.dart';

/// Typed result used across the app: [Left] is a [Failure], [Right] is success.
typedef Result<T> = Either<Failure, T>;

/// Base failure for the domain layer. A native `sealed` class keeps the error
/// model exhaustive without pulling codegen into every error site.
sealed class Failure {
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
