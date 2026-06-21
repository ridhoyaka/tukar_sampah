import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/calculator/screens/calculator_screen.dart';
import '../features/pickup/screens/pickup_screen.dart';
import '../features/pickup/screens/schedule_pickup_screen.dart';
import '../features/catalog/screens/catalog_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/home/screens/main_shell.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_catalog_screen.dart';
import '../features/admin/screens/admin_pickups_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import '../core/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Belum login → paksa ke login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Sudah login tapi masih di halaman auth → redirect sesuai role
      // (role di-handle di login_screen langsung via context.go)
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // User routes
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/calculator',
            builder: (context, state) => const CalculatorScreen(),
          ),
          GoRoute(
            path: '/pickup',
            builder: (context, state) => const PickupScreen(),
          ),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/schedule-pickup',
        builder: (context, state) => const SchedulePickupScreen(),
      ),
      // Admin routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/catalog',
            builder: (context, state) => const AdminCatalogScreen(),
          ),
          GoRoute(
            path: '/admin/pickups',
            builder: (context, state) => const AdminPickupsScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
        ],
      ),
    ],
  );
});
