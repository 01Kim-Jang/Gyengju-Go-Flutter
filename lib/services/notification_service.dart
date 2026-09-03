import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// "근처에 새 스탬프가 있어요" 알림. 서버 푸시(FCM) 없이, 앱이 이미 계속 받고 있는
// GPS 위치 업데이트만으로 판단하는 로컬 알림이다 — 벌써 Firebase Blaze(종량제) 없이도
// 동작하는 구조(Cloudflare Worker 프록시 등)를 지켜온 것과 같은 이유로, 별도 서버
// 비용/구성 없이 구현 가능한 이 방식을 선택했다.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init Error: $e');
    }
  }

  static Future<void> showNearbyStamp({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'nearby_stamp_channel',
        'Nearby Stamps',
        channelDescription: '근처 미방문 명소(스탬프) 알림',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('NotificationService.showNearbyStamp Error: $e');
    }
  }
}
