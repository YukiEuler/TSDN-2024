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
    apiKey: 'AIzaSyBOebspZGpbN2IKu0VdlszM4nkWFStN0so',
    appId: '1:695313956830:web:226c470f20bd6f0440274f',
    messagingSenderId: '695313956830',
    projectId: 'tsdn-monkeypox',
    authDomain: 'tsdn-monkeypox.firebaseapp.com',
    storageBucket: 'tsdn-monkeypox.firebasestorage.app',
    measurementId: 'G-XSEKQ21724',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA72zxfDSfmKxidtOExe6prg1Eg7ozEZLY',
    appId: '1:695313956830:android:488b19fbaa95571940274f',
    messagingSenderId: '695313956830',
    projectId: 'tsdn-monkeypox',
    storageBucket: 'tsdn-monkeypox.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDeYvpOamXJhvK_doK1T-kMxoPPVnGRLY',
    appId: '1:695313956830:ios:cac20328c3520ed940274f',
    messagingSenderId: '695313956830',
    projectId: 'tsdn-monkeypox',
    storageBucket: 'tsdn-monkeypox.firebasestorage.app',
    iosBundleId: 'org.tsdn.monkeypox.tsdnMonkeypox',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDeYvpOamXJhvK_doK1T-kMxoPPVnGRLY',
    appId: '1:695313956830:ios:cac20328c3520ed940274f',
    messagingSenderId: '695313956830',
    projectId: 'tsdn-monkeypox',
    storageBucket: 'tsdn-monkeypox.firebasestorage.app',
    iosBundleId: 'org.tsdn.monkeypox.tsdnMonkeypox',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBOebspZGpbN2IKu0VdlszM4nkWFStN0so',
    appId: '1:695313956830:web:c2a1eb0cc5c4af2540274f',
    messagingSenderId: '695313956830',
    projectId: 'tsdn-monkeypox',
    authDomain: 'tsdn-monkeypox.firebaseapp.com',
    storageBucket: 'tsdn-monkeypox.firebasestorage.app',
    measurementId: 'G-8MXT0R1403',
  );
}