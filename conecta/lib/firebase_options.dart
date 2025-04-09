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
    apiKey: 'AIzaSyDNxPN5tOw_vFgAVqoDUO9FBntUzvnJJkk',
    appId: '1:1092115090674:web:d229ce73b9c8c72addd46b',
    messagingSenderId: '1092115090674',
    projectId: 'conectadam-924b7',
    authDomain: 'conectadam-924b7.firebaseapp.com',
    storageBucket: 'conectadam-924b7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmZya0ee1NCmA-bQlGYxETTeeiEKD-SpE',
    appId: '1:1092115090674:android:75f838acc46d4e9cddd46b',
    messagingSenderId: '1092115090674',
    projectId: 'conectadam-924b7',
    storageBucket: 'conectadam-924b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQItVQo5hDSRMfAV6_w_eysBDqoyeaydU',
    appId: '1:1092115090674:ios:fcd9045b9e1b6de9ddd46b',
    messagingSenderId: '1092115090674',
    projectId: 'conectadam-924b7',
    storageBucket: 'conectadam-924b7.firebasestorage.app',
    iosBundleId: 'com.example.conecta',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQItVQo5hDSRMfAV6_w_eysBDqoyeaydU',
    appId: '1:1092115090674:ios:fcd9045b9e1b6de9ddd46b',
    messagingSenderId: '1092115090674',
    projectId: 'conectadam-924b7',
    storageBucket: 'conectadam-924b7.firebasestorage.app',
    iosBundleId: 'com.example.conecta',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDNxPN5tOw_vFgAVqoDUO9FBntUzvnJJkk',
    appId: '1:1092115090674:web:7b969bfba9249989ddd46b',
    messagingSenderId: '1092115090674',
    projectId: 'conectadam-924b7',
    authDomain: 'conectadam-924b7.firebaseapp.com',
    storageBucket: 'conectadam-924b7.firebasestorage.app',
  );
}
