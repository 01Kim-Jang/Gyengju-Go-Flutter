// 플레이스홀더 파일입니다.
// `flutterfire configure` 실행 시 이 파일 전체가 실제 프로젝트 설정값으로 자동 교체됩니다.
// (README의 "Firebase 설정" 섹션 참고)
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
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}
