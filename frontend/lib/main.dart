import 'package:dashbaord/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dashbaord/constants/app_theme.dart';
import 'package:dashbaord/firebase_options.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apiServices = ApiServices();
  await apiServices.configureDio();

  _initializeNotifications();
  _requestNotificationPermissions();
  clearAllNotifications();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      //TODO: Handle tapping on a notification
    },
  );
}

Future<void> _requestNotificationPermissions() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> clearAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool isLoggedIn = false;

  int status = 0;
  int totalOperation = 1;
  void changeState() {
    setState(() {
      status++;
      if (status >= totalOperation) {
        isLoading = false;
      }
    });
  }

  setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await handleMessage(message);
    });
  }

  //handling foreground messages
  Future<void> handleMessage(RemoteMessage message) async {
    final notificationTitle = message.notification?.title ?? 'No Title';
    final notificationBody = message.notification?.body ?? 'No Body';

    // Show local notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('dashboard-channel',
            'IITH Dashboard Channel', // TODO: later use good channel id and names [like differnt for each type of notification]
            importance: Importance.max,
            priority: Priority.high);

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
    );
  }

  getAuthStatus() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    setState(() {
      if (user != null) {
        isLoggedIn = true;
      }
    });
    changeState();
  }

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    getAuthStatus();
    getThemeMode();
    setupFirebaseListeners();
  }

  getThemeMode() async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    int? mode = prefs.getInt(themeKey);
    setState(() {
      _mode = mode;
    });
    changeState();
  }

  setThemeMode(int val) async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, val);
  }

  int? _mode;

  void handleThemeChange(int theme) {
    setState(() {
      if (theme == 1) {
        _mode = 1;
      } else if (theme == 2) {
        _mode = 2;
      } else {
        _mode = 0;
      }
    });

    setThemeMode(theme);
  }

  statusIconBarColor() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    if (brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark));
    }
  }

  @override
  Widget build(BuildContext context) {
    statusIconBarColor();
    return MaterialApp.router(
      routerConfig: AppRouter(onThemeChanged: handleThemeChange).router,
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _mode == null || _mode == 0
          ? ThemeMode.system
          : _mode == 1
              ? ThemeMode.light
              : ThemeMode.dark,
      // navigatorObservers: [_analyticsService.getAnalyticsObserver()],
      // home: isLoading
      //     ? SplashScreen(nextPage: Container())
      //     : isLoggedIn
      //         ? SplashScreen(
      //             nextPage: HomeScreen(
      //               onThemeChanged: handleThemeChange,
      //               isGuest: false,
      //             ),
      //             isLoading: false,
      //           )
      //         : SplashScreen(
      //             isLoading: false,
      //             nextPage: LoginScreenWrapper(
      //               onThemeChanged: handleThemeChange,
      //               timeDilationFactor: 4.0,
      //             )),
    );
  }
}
