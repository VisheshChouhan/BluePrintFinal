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
    apiKey: 'AIzaSyB_xHmooKr9ptoVQOJeFF519Z9f3fHveeI',
    appId: '1:533764852792:web:39c8d50c8cad9b6d52eacd',
    messagingSenderId: '533764852792',
    projectId: 'blueprint-de447',
    authDomain: 'blueprint-de447.firebaseapp.com',
    storageBucket: 'blueprint-de447.appspot.com',
    measurementId: 'G-DTXMRBVXBH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCsCC6UmOt7gbxESmR_mN7QS_pDVrh2HY',
    appId: '1:533764852792:android:667be50c5f1a38dc52eacd',
    messagingSenderId: '533764852792',
    projectId: 'blueprint-de447',
    storageBucket: 'blueprint-de447.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjM7E_Rc6nducGDzrQ08a6kVf6-VnGWhw',
    appId: '1:533764852792:ios:49df66001baf9ba952eacd',
    messagingSenderId: '533764852792',
    projectId: 'blueprint-de447',
    storageBucket: 'blueprint-de447.appspot.com',
    iosBundleId: 'com.example.bluePrint',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDjM7E_Rc6nducGDzrQ08a6kVf6-VnGWhw',
    appId: '1:533764852792:ios:49df66001baf9ba952eacd',
    messagingSenderId: '533764852792',
    projectId: 'blueprint-de447',
    storageBucket: 'blueprint-de447.appspot.com',
    iosBundleId: 'com.example.bluePrint',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB_xHmooKr9ptoVQOJeFF519Z9f3fHveeI',
    appId: '1:533764852792:web:5a252042ce23c94452eacd',
    messagingSenderId: '533764852792',
    projectId: 'blueprint-de447',
    authDomain: 'blueprint-de447.firebaseapp.com',
    storageBucket: 'blueprint-de447.appspot.com',
    measurementId: 'G-2YZYE4TTTS',
  );
}
