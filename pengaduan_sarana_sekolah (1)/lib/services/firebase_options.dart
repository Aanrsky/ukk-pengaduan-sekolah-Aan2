import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhJ-mz3MJ_8L_srFtrDCCIFa_vBhdq_V4',
    appId: '1:443292713411:android:407e5f2eb87bb3ef17bd76',
    messagingSenderId: '443292713411',
    projectId: 'pengaduan-skolah',
    storageBucket: 'pengaduan-skolah.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhwREWnyT1qevtsF0eXWzM_Dat5grmuwA',
    appId: '1:443292713411:web:7d55cc75d9a5fc9d17bd76',
    messagingSenderId: '443292713411',
    projectId: 'pengaduan-skolah',
    authDomain: 'pengaduan-skolah.firebaseapp.com',
    storageBucket: 'pengaduan-skolah.firebasestorage.app',
    measurementId: 'G-G3LBQVW13S',
  );
}
