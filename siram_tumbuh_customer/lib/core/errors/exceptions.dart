/// Base exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class BadResponseException extends AppException {
  final int statusCode;
  const BadResponseException(this.statusCode, super.message);
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Generic exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
