import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 android/web 플랫폼만 지원합니다. '
          '`flutterfire configure`를 아직 실행하지 않으셨다면 README를 참고해 먼저 실행해주세요.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAs0XlbAhraIB2TNdcvp3xIyOb6vpG7FOQ',
    appId: '1:186888075344:web:341c865872eb06fe59f955',
    messagingSenderId: '186888075344',
    projectId: 'gyengju-go',
    authDomain: 'gyengju-go.firebaseapp.com',
    storageBucket: 'gyengju-go.firebasestorage.app',
    measurementId: 'G-CEV4P5ZDF2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgkxf9QGSvvSk5nQSKuDUCvjH7l18Z1C4',
    appId: '1:186888075344:android:b4d3c1b4ad3f689f59f955',
    messagingSenderId: '186888075344',
    projectId: 'gyengju-go',
    storageBucket: 'gyengju-go.firebasestorage.app',
  );
}
