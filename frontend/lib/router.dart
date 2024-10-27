import 'package:dashbaord/constants/enums/lost_and_found.dart';
import 'package:dashbaord/error.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/screens/bus_timings_screen.dart';
import 'package:dashbaord/screens/cab_add_screen.dart';
import 'package:dashbaord/screens/cab_add_success.dart';
import 'package:dashbaord/screens/cab_sharing_screen.dart';
import 'package:dashbaord/screens/home_screen.dart';
import 'package:dashbaord/screens/login_screen.dart';
import 'package:dashbaord/screens/lost_and_found_add_item_screen.dart';
import 'package:dashbaord/screens/lost_and_found_item_screen.dart';
import 'package:dashbaord/screens/lost_and_found_screen.dart';
import 'package:dashbaord/screens/mess_menu_screen.dart';
import 'package:dashbaord/screens/profile_screen.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static AppRouter? _instance;

  factory AppRouter({required Function(int) onThemeChanged}) {
    _instance ??= AppRouter._internal(onThemeChanged: onThemeChanged);
    return _instance!;
  }

  AppRouter._internal({required this.onThemeChanged});

  final Function(int) onThemeChanged;

  bool getAuthStatus() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user != null;
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isLoggedIn = getAuthStatus();

          // Only redirect if the user is at the root path (`/`)
          if (state.fullPath == '/') {
            return isLoggedIn ? '/home' : '/login';
          }

          return null;
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final isGuest = data['isGuest'] as bool? ?? false;

          return HomeScreen(
            isGuest: isGuest,
            onThemeChanged: onThemeChanged,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final timeDilationFactor =
              data['timeDilationFactor'] as double? ?? 1.0;

          return LoginScreenWrapper(
            timeDilationFactor: timeDilationFactor,
            onThemeChanged: onThemeChanged,
          );
        },
      ),
      GoRoute(
        path: '/me',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final user = data['user'] as UserModel?;
          final image = data['image'] as String?;

          return ProfileScreen(
            user: user,
            image: image,
            onThemeChanged: onThemeChanged,
          );
        },
      ),
      GoRoute(
        path: '/cabsharing',
        builder: (context, state) {
          final isMeStr = state.uri.queryParameters['me'];
          final startTimeString = state.uri.queryParameters['startTime'];
          final endTimeString = state.uri.queryParameters['endTime'];
          final from = state.uri.queryParameters['from'];
          final to = state.uri.queryParameters['to'];

          bool? isMe;

          if (isMeStr == 'true') {
            isMe = true;
          } else if (isMeStr == 'false') {
            isMe = false;
          }

          final startTime =
              startTimeString != null ? DateTime.parse(startTimeString) : null;
          final endTime =
              endTimeString != null ? DateTime.parse(endTimeString) : null;

          final data = state.extra as Map<String, dynamic>? ?? {};
          final user = data['user'] as UserModel?;
          final image = data['image'] as String?;
          final isMyRide = data['isMyRide'] as bool? ?? false;

          return CabSharingScreen(
            user: user,
            image: image,
            isMyRide: isMe ?? isMyRide,
            startTime: startTime,
            endTime: endTime,
            from: from,
            to: to,
          );
        },
      ),
      GoRoute(
        path: '/cabsharing/add',
        pageBuilder: (context, state) {
          final fromLocation = state.uri.queryParameters['from'];
          final toLocation = state.uri.queryParameters['to'];
          final start = state.uri.queryParameters['start'];
          final end = state.uri.queryParameters['end'];
          final seats = state.uri.queryParameters['seats'];
          final comments = state.uri.queryParameters['comments'];

          return CustomTransitionPage(
            key: state.pageKey,
            child: CabAddScreen(
              from: fromLocation,
              to: toLocation,
              startTime: start,
              endTime: end,
              seats: seats,
              comments: comments,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/cabsharing/add/success',
        builder: (context, state) {
          return CabAddSuccess();
        },
      ),
      GoRoute(
        path: '/lnf',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final currentUserEmail = data['currentUserEmail'] as String?;

          return LostAndFoundScreen(
            currentUserEmail: currentUserEmail,
          );
        },
      ),
      GoRoute(
        path: '/lnf/add',
        builder: (context, state) {
          return LostAndFoundAddItemScreen();
        },
      ),
      GoRoute(
        path: '/lnf/:item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final item = state.pathParameters['item'];

          if (id == null) {
            return const ErrorScreen();
          }

          LostOrFound lrf;
          if (item == 'lost') {
            lrf = LostOrFound.lost;
          } else if (item == 'found') {
            lrf = LostOrFound.found;
          } else {
            return const ErrorScreen();
          }

          final data = state.extra as Map<String, dynamic>? ?? {};
          final currentUserEmail = data['currentUserEmail'] as String?;

          return LostAndFoundItemScreen(
            currentUserEmail: currentUserEmail,
            id: id,
            lostOrFound: lrf,
          );
        },
      ),
      GoRoute(
        path: '/mess',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final messMenu = data['messMenu'] as MessMenuModel?;

          return MessMenuScreen(
            messMenu: messMenu,
          );
        },
      ),
      GoRoute(
        path: '/bus',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final busSchedule = data['busSchedule'] as BusSchedule?;

          return BusTimingsScreen(
            busSchedule: busSchedule,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}
