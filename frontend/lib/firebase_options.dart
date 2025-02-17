// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCGwHvbCTCmmZHI1AG_2LW62zIGZl_eAEo',
    appId: '1:472121739465:web:28e3fd4ec06b8a3f9d6518',
    messagingSenderId: '472121739465',
    projectId: 'dashboard-iith',
    authDomain: 'dashboard-iith.firebaseapp.com',
    storageBucket: 'dashboard-iith.firebasestorage.app',
    measurementId: 'G-32K0B7S4PL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1yUytVpk3j4kIIOGXgW3_3cEMm0OaUo0',
    appId: '1:472121739465:android:e7080caa6f17001e9d6518',
    messagingSenderId: '472121739465',
    projectId: 'dashboard-iith',
    storageBucket: 'dashboard-iith.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCF6912XrlY_LAEws85ddea2Xgp2-_cjV8',
    appId: '1:472121739465:ios:a4dbe663d3457a9e9d6518',
    messagingSenderId: '472121739465',
    projectId: 'dashboard-iith',
    storageBucket: 'dashboard-iith.firebasestorage.app',
    androidClientId: '472121739465-1bjrrunahhk2962jvsn5tfpro79gsm37.apps.googleusercontent.com',
    iosClientId: '472121739465-de4k347d2utj3rb1tk401ojtnlgsg5ib.apps.googleusercontent.com',
    iosBundleId: 'dev.iith.dashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCF6912XrlY_LAEws85ddea2Xgp2-_cjV8',
    appId: '1:472121739465:ios:a4dbe663d3457a9e9d6518',
    messagingSenderId: '472121739465',
    projectId: 'dashboard-iith',
    storageBucket: 'dashboard-iith.firebasestorage.app',
    androidClientId: '472121739465-1bjrrunahhk2962jvsn5tfpro79gsm37.apps.googleusercontent.com',
    iosClientId: '472121739465-de4k347d2utj3rb1tk401ojtnlgsg5ib.apps.googleusercontent.com',
    iosBundleId: 'dev.iith.dashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAx3fwU5XQo-OayM3jof-NU0tkUGDUbZd4',
    appId: '1:472121739465:web:256a539e1467b46f9d6518',
    messagingSenderId: '472121739465',
    projectId: 'dashboard-iith',
    authDomain: 'dashboard-iith.firebaseapp.com',
    storageBucket: 'dashboard-iith.firebasestorage.app',
    measurementId: 'G-TDPZFCL0SW',
  );

}