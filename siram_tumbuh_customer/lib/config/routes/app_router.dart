import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder screens - to be implemented
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/catalog/presentation/screens/main_screen.dart';
import '../../features/catalog/presentation/screens/service_detail_screen.dart';
import '../../features/catalog/presentation/screens/promo_detail_screen.dart';
import '../../features/catalog/presentation/providers/promo_provider.dart';
import '../../features/catalog/domain/entities/service_item.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/chat/presentation/screens/consultation_chat_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String name;
  const PlaceholderScreen({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$name Screen'),
      ),
    );
  }
}

/// Route names
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  // Nested route paths (relative - without leading slash)
  static const String services = 'services';
  static const String serviceDetail = 'services/:id';
  static const String promoDetail = 'promo/:id';
  static const String booking = 'booking';
  static const String bookingDetail = 'booking/:id';
  static const String projects = 'projects';
  static const String projectDetail = 'projects/:id';
  static const String projectProgress = 'projects/:id/progress';
  static const String profile = 'profile';
  static const String chat = 'chat';
  static const String notifications = 'notifications';
  
  // Full route paths for navigation
  static const String fullServices = '/home/services';
  static const String fullBooking = '/home/booking';
  static const String fullProjects = '/home/projects';
  static const String fullProfile = '/home/profile';
}

/// GoRouter configuration
final goRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: Routes.login,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) =>
            const PlaceholderScreen(name: 'Splash'),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: Routes.services,
            builder: (context, state) =>
                const PlaceholderScreen(name: 'Services'),
          ),
          GoRoute(
            path: Routes.serviceDetail,
            builder: (context, state) {
              if (state.extra == null) return const MainScreen();
              final service = state.extra as ServiceItem;
              return ServiceDetailScreen(service: service);
            },
          ),
          GoRoute(
            path: Routes.promoDetail,
            builder: (context, state) {
              if (state.extra == null) return const MainScreen();
              final promo = state.extra as Promo;
              return PromoDetailScreen(promo: promo);
            },
          ),
          GoRoute(
            path: Routes.booking,
            builder: (context, state) {
              if (state.extra == null) return const MainScreen();
              final service = state.extra as ServiceItem;
              return BookingScreen(service: service);
            },
          ),
          GoRoute(
            path: 'booking/confirmation',
            builder: (context, state) => const BookingConfirmationScreen(),
          ),
          GoRoute(
            path: Routes.projects,
            builder: (context, state) =>
                const ProjectListScreen(),
          ),
          GoRoute(
            path: Routes.projectDetail,
            builder: (context, state) {
              final project = state.extra as Project;
              return ProjectDetailScreen(initialProject: project);
            },
          ),
          GoRoute(
            path: Routes.projectProgress,
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return PlaceholderScreen(name: 'Project Progress - $id');
            },
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) =>
                const ProfileScreen(),
          ),
          GoRoute(
            path: Routes.chat,
            builder: (context, state) {
              final service = state.extra as ServiceItem?;
              return ConsultationChatScreen(service: service);
            },
          ),
          GoRoute(
            path: Routes.notifications,
            builder: (context, state) => const NotificationScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
