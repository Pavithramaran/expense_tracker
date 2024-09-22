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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAf4EQv4B_9vEoZSWgOEzN6Fnd0Fxqwh4E',
    appId: '1:456221946754:web:cc7088d6a3243fd2c7559b',
    messagingSenderId: '456221946754',
    projectId: 'framework-9b35b',
    authDomain: 'framework-9b35b.firebaseapp.com',
    storageBucket: 'framework-9b35b.appspot.com',
    measurementId: 'G-66W9C5QRYF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrSM-iv7-9jypw683-uMuAn4qHR4uGUb0',
    appId: '1:456221946754:android:a03ad2a9922ca761c7559b',
    messagingSenderId: '456221946754',
    projectId: 'framework-9b35b',
    storageBucket: 'framework-9b35b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDu1SziOzDdak86iaHGIIP9Y-L3gb1PQoE',
    appId: '1:456221946754:ios:a2480e537e460cd1c7559b',
    messagingSenderId: '456221946754',
    projectId: 'framework-9b35b',
    storageBucket: 'framework-9b35b.appspot.com',
    iosBundleId: 'com.example.expencesTracker',
  );

}