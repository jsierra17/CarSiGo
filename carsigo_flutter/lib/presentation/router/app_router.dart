import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/trip_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/trip/request_trip_screen.dart';
import '../screens/trip/trip_details_screen.dart';
import '../screens/trip/trip_history_screen.dart';
import '../screens/location/saved_locations_screen.dart';
import '../screens/location/add_location_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/support/create_ticket_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String trip = '/trip';
  static const String profile = '/profile';
  static const String requestTrip = '/request-trip';
  static const String tripDetails = '/trip-details';
  static const String tripHistory = '/trip-history';
  static const String savedLocations = '/saved-locations';
  static const String addLocation = '/add-location';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String support = '/support';
  static const String createTicket = '/create-ticket';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.uri}'),
      ),
    ),
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Navigation
      GoRoute(
        path: main,
        name: main,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: home,
            name: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: trip,
            name: trip,
            builder: (context, state) => const TripScreen(),
          ),
          GoRoute(
            path: profile,
            name: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Trip Routes
      GoRoute(
        path: requestTrip,
        name: requestTrip,
        builder: (context, state) => const RequestTripScreen(),
      ),
      GoRoute(
        path: tripDetails,
        name: tripDetails,
        builder: (context, state) {
          final viajeId = int.tryParse(state.uri.queryParameters['viajeId'] ?? '');
          return TripDetailsScreen(viajeId: viajeId);
        },
      ),
      GoRoute(
        path: tripHistory,
        name: tripHistory,
        builder: (context, state) => const TripHistoryScreen(),
      ),

      // Location Routes
      GoRoute(
        path: savedLocations,
        name: savedLocations,
        builder: (context, state) => const SavedLocationsScreen(),
      ),
      GoRoute(
        path: addLocation,
        name: addLocation,
        builder: (context, state) {
          final ubicacionId = state.uri.queryParameters['ubicacionId'];
          return AddLocationScreen(ubicacionId: ubicacionId);
        },
      ),

      // Profile Routes
      GoRoute(
        path: editProfile,
        name: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: changePassword,
        name: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Support Routes
      GoRoute(
        path: support,
        name: support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: createTicket,
        name: createTicket,
        builder: (context, state) => const CreateTicketScreen(),
      ),
    ],
  );

  // Navigation helpers
  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToRegister(BuildContext context) {
    context.go(register);
  }

  static void goToMain(BuildContext context) {
    context.go(main);
  }

  static void goToHome(BuildContext context) {
    context.go('$main/$home');
  }

  static void goToTrip(BuildContext context) {
    context.go('$main/$trip');
  }

  static void goToProfile(BuildContext context) {
    context.go('$main/$profile');
  }

  static void goToRequestTrip(BuildContext context) {
    context.go(requestTrip);
  }

  static void goToTripDetails(BuildContext context, int viajeId) {
    context.go('$tripDetails?viajeId=$viajeId');
  }

  static void goToTripHistory(BuildContext context) {
    context.go(tripHistory);
  }

  static void goToSavedLocations(BuildContext context) {
    context.go(savedLocations);
  }

  static void goToAddLocation(BuildContext context, {String? ubicacionId}) {
    if (ubicacionId != null) {
      context.go('$addLocation?ubicacionId=$ubicacionId');
    } else {
      context.go(addLocation);
    }
  }

  static void goToEditProfile(BuildContext context) {
    context.go(editProfile);
  }

  static void goToChangePassword(BuildContext context) {
    context.go(changePassword);
  }

  static void goToSupport(BuildContext context) {
    context.go(support);
  }

  static void goToCreateTicket(BuildContext context) {
    context.go(createTicket);
  }

  // Back navigation
  static void goBack(BuildContext context) {
    context.pop();
  }

  // Replace navigation
  static void replaceWithLogin(BuildContext context) {
    context.goReplacement(login);
  }

  static void replaceWithMain(BuildContext context) {
    context.goReplacement(main);
  }
}
