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

  // Web 앱이 Console에 아직 없을 때를 대비해, 동일 프로젝트(gyengju-go)의
  // Android 자격증명 + 웹용 authDomain을 사용한다.
  // (정식으로는 `flutterfire configure --platforms=web`로 web appId를 채우는 것이 권장.)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgkxf9QGSvvSk5nQSKuDUCvjH7l18Z1C4',
    appId: '1:186888075344:android:b4d3c1b4ad3f689f59f955',
    messagingSenderId: '186888075344',
    projectId: 'gyengju-go',
    authDomain: 'gyengju-go.firebaseapp.com',
    storageBucket: 'gyengju-go.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgkxf9QGSvvSk5nQSKuDUCvjH7l18Z1C4',
    appId: '1:186888075344:android:b4d3c1b4ad3f689f59f955',
    messagingSenderId: '186888075344',
    projectId: 'gyengju-go',
    storageBucket: 'gyengju-go.firebasestorage.app',
  );
}
