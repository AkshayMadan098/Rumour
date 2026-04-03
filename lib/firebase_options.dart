import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrtnra3uJE4fpgEi2IbEiRz6GmFHxWpsY',
    appId: '1:125345293329:web:your_web_id', 
    messagingSenderId: '125345293329',
    projectId: 'newapp-437306',
    authDomain: 'newapp-437306.firebaseapp.com',
    storageBucket: 'newapp-437306.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrtnra3uJE4fpgEi2IbEiRz6GmFHxWpsY',
    appId: '1:125345293329:android:801777b37c425f8063fdb0',
    messagingSenderId: '125345293329',
    projectId: 'newapp-437306',
    storageBucket: 'newapp-437306.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrtnra3uJE4fpgEi2IbEiRz6GmFHxWpsY',
    appId: '1:125345293329:ios:your_ios_id', // REPLACE THIS with your iOS App ID from Firebase Console
    messagingSenderId: '125345293329',
    projectId: 'newapp-437306',
    storageBucket: 'newapp-437306.firebasestorage.app',
    iosBundleId: 'com.example.rumour',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDrtnra3uJE4fpgEi2IbEiRz6GmFHxWpsY',
    appId: '1:125345293329:ios:your_ios_id', // REPLACE THIS
    messagingSenderId: '125345293329',
    projectId: 'newapp-437306',
    storageBucket: 'newapp-437306.firebasestorage.app',
    iosBundleId: 'com.example.rumour',
  );
}
