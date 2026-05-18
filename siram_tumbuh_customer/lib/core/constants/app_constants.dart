/// Application wide constants
class AppConstants {
  static const String appName = 'Siram Tumbuh - Customer';
  static const String appVersion = '1.0.0';

  /// API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  /// Pagination
  static const int pageSize = 10;

  /// Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
}

class AppEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';

  // Services
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String searchServices = '/services/search';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingDetail = '/bookings/:id';
  static const String myBookings = '/bookings/my-bookings';

  // Projects
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String projectProgress = '/projects/:id/progress';
  static const String uploadProgress = '/projects/:id/progress/upload';
}
