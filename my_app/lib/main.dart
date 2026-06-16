import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/forgot_otp_screen.dart';

import 'features/auth/login_success_screen.dart';
import 'features/auth/verification_success_screen.dart';
import 'features/auth/new_password_screen.dart';
import 'features/auth/password_changed_screen.dart';
import 'features/auth/terms_privacy_screen.dart';

import 'features/profile/create_profile_screen.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/scan_food_screen.dart';
import 'features/dashboard/food_detected_screen.dart';
import 'features/dashboard/risk_analysis_screen.dart';
import 'features/dashboard/detailed_report_screen.dart';
import 'features/dashboard/type_food_screen.dart';
import 'features/dashboard/video_player_screen.dart';
import 'features/dashboard/add_food_screen.dart';

import 'features/dashboard/videos_watched_screen.dart';
import 'features/dashboard/my_profile_screen.dart';
import 'features/dashboard/history_screen.dart';
import 'features/dashboard/daily_progress_screen.dart';
import 'features/dashboard/daily_water_intake_screen.dart';

void main() {
  runApp(const MainApp());
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 90,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              "Page Not Found",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text("Go Home"),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
    /// SPLASH
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    /// ONBOARDING
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    /// TERMS
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsPrivacyScreen(),
    ),

    /// LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// SIGNUP
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return OtpScreen(
          name: extra?['name'] ?? '',
          email: extra?['email'] ?? '',
          password: extra?['password'] ?? '',
          otp: extra?['otp'] ?? '',
          savePassword: extra?['savePassword'] ?? true,
        );
      },
    ),

    /// VERIFICATION SUCCESS
    GoRoute(
      path: '/verification-success',
      builder: (context, state) => const VerificationSuccessScreen(),
    ),

    /// FORGOT PASSWORD
    GoRoute(
      path: '/forgot',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/forgot-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;

        return ForgotOtpScreen(
          email: extra?['email'] ?? '',
          otp: extra?['otp'] ?? '',
        );
      },
    ),

    /// NEW PASSWORD
    GoRoute(
      path: '/new-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';

        return NewPasswordScreen(
          email: email,
        );
      },
    ),

    /// PASSWORD CHANGED
    GoRoute(
      path: '/password-changed',
      builder: (context, state) => const PasswordChangedScreen(),
    ),

    /// LOGIN SUCCESS
    GoRoute(
      path: '/login-success',
      builder: (context, state) {
        final email = state.extra as String? ?? '';

        return LoginSuccessScreen(
          email: email,
        );
      },
    ),

    /// CREATE PROFILE
    GoRoute(
      path: '/create-profile',
      builder: (context, state) {
        final email = state.extra as String? ?? '';

        return CreateProfileScreen(
          email: email,
        );
      },
    ),

    /// DASHBOARD
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    /// SCAN FOOD
    GoRoute(
      path: '/scan-food',
      builder: (context, state) => const ScanFoodScreen(),
    ),

    /// FOOD DETECTED
    GoRoute(
      path: '/food-detected',
      builder: (context, state) {
        final foodData = state.extra as Map<String, dynamic>;

        return FoodDetectedScreen(
          foodData: foodData,
        );
      },
    ),

    /// RISK ANALYSIS
    GoRoute(
      path: '/risk-analysis',
      builder: (context, state) {
        final foodData = state.extra as Map<String, dynamic>;

        return RiskAnalysisScreen(
          foodData: foodData,
        );
      },
    ),

    /// DETAILED REPORT
    GoRoute(
      path: '/detailed-report',
      builder: (context, state) {
        final foodData = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};

        return DetailedReportScreen(foodData: foodData);
      },
    ),

    /// TYPE FOOD
    GoRoute(
      path: '/type-food',
      builder: (context, state) => const TypeFoodScreen(),
    ),

    /// VIDEO PLAYER
    GoRoute(
      path: '/video-player',
      builder: (context, state) {
        final videoData = state.extra as Map<String, dynamic>;

        return VideoPlayerScreen(
          videoData: videoData,
        );
      },
    ),

    /// ADD FOOD
    GoRoute(
      path: '/add-food',
      builder: (context, state) => const AddFoodScreen(),
    ),

    /// VIDEOS WATCHED
    GoRoute(
      path: '/videos-watched',
      builder: (context, state) => const VideosWatchedScreen(),
    ),

    /// MY PROFILE
    GoRoute(
      path: '/my-profile',
      builder: (context, state) => const MyProfileScreen(),
    ),

    /// HISTORY
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),

    /// DAILY PROGRESS
    GoRoute(
      path: '/daily-progress',
      builder: (context, state) => const DailyProgressScreen(),
    ),

    /// DAILY WATER
    GoRoute(
      path: '/daily-water',
      builder: (context, state) => const DailyWaterIntakeScreen(),
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Oral Diet',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
