/// Base failure class for error handling
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

class BadResponseFailure extends Failure {
  final int? statusCode;
  const BadResponseFailure(super.message, {this.statusCode});
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
