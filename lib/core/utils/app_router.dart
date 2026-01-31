import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/create_account_screen.dart';
import '../presentation/screens/auth/profile_setup_screen.dart';
import '../presentation/screens/auth/welcome_choice_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/learning/learning_session_screen.dart';
import '../presentation/screens/journey/journey_screen.dart';
import '../presentation/screens/analytics/analytics_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/screening/screening_intro_screen.dart';
import '../presentation/screens/screening/screening_task_hub.dart';
import '../presentation/screens/screening/screening_result_screen.dart';
import '../presentation/screens/screening/tasks/handwriting_task_screen.dart';
import '../presentation/screens/screening/tasks/voice_task_screen.dart';
import '../presentation/screens/screening/tasks/typing_task_screen.dart';
import '../presentation/screens/screening/speech_test_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String profileSetup = '/profile-setup';
  static const String welcomeChoice = '/welcome-choice';
  static const String screeningIntro = '/screening-intro';
  static const String screeningHub = '/screening-hub';
  static const String screeningHandwriting = '/screening-handwriting';
  static const String screeningVoice = '/screening-voice';
  static const String screeningTyping = '/screening-typing';
  static const String screeningResult = '/screening-result';
  static const String speechTest = '/speech-test';
  static const String dashboard = '/dashboard';
  static const String learningSession = '/learning-session';
  static const String journey = '/journey';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: createAccount,
        name: 'createAccount',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateAccountScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: welcomeChoice,
        name: 'welcomeChoice',
        pageBuilder: (context, state) {
          final isExisting = state.uri.queryParameters['existing'] == 'true';
          return CustomTransitionPage(
            key: state.pageKey,
            child: WelcomeChoiceScreen(isExistingUser: isExisting),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: profileSetup,
        name: 'profileSetup',
        pageBuilder: (context, state) {
          final age = int.tryParse(state.uri.queryParameters['age'] ?? '7') ?? 7;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileSetupScreen(userAge: age),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: screeningIntro,
        name: 'screeningIntro',
        pageBuilder: (context, state) {
          final age = int.tryParse(state.uri.queryParameters['age'] ?? '7') ?? 7;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ScreeningIntroScreen(userAge: age),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: screeningHub,
        name: 'screeningHub',
        pageBuilder: (context, state) {
          final age = int.tryParse(state.uri.queryParameters['age'] ?? '7') ?? 7;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ScreeningTaskHub(userAge: age),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: screeningHandwriting,
        name: 'screeningHandwriting',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HandwritingTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: screeningVoice,
        name: 'screeningVoice',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const VoiceTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: screeningTyping,
        name: 'screeningTyping',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TypingTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: screeningResult,
        name: 'screeningResult',
        pageBuilder: (context, state) {
          final handwriting = double.tryParse(state.uri.queryParameters['handwriting'] ?? '0.0') ?? 0.0;
          final voice = double.tryParse(state.uri.queryParameters['voice'] ?? '0.0') ?? 0.0;
          final typing = double.tryParse(state.uri.queryParameters['typing'] ?? '0.0') ?? 0.0;
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: ScreeningResultScreen(
              handwritingScore: handwriting,
              voiceScore: voice,
              typingScore: typing,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: speechTest,
        name: 'speechTest',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SpeechTestScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: learningSession,
        name: 'learningSession',
        pageBuilder: (context, state) {
          final dayNumber = state.uri.queryParameters['day'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: LearningSessionScreen(
              dayNumber: dayNumber != null ? int.parse(dayNumber) : 1,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: journey,
        name: 'journey',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const JourneyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: analytics,
        name: 'analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AnalyticsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}
