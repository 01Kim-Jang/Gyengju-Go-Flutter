import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Firebase 익명 인증 + Firestore users/{uid} 프로필(닉네임, 캐릭터, 친구코드) 관리.
//
// `flutterfire configure`를 아직 실행하지 않아 Firebase가 초기화되지 않은 상태에서도
// (친구/파티 기능을 제외한) 앱의 나머지 기능이 죽지 않도록, Firebase 미초기화 시
// 모든 메서드가 예외를 던지는 대신 조용히 무효(null/no-op)를 반환한다.
class UserService {
  static const String _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 0/O, 1/I 제외

  static bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  // users/{uid}는 친구코드 검색 때문에 모든 로그인 사용자가 서로 읽을 수 있으므로,
  // 위치처럼 민감한 데이터는 별도 컬렉션(locations/{uid})에 두고 firestore.rules에서
  // 본인 또는 실제 친구 관계인 경우에만 읽을 수 있도록 엄격히 제한한다.
  static CollectionReference<Map<String, dynamic>> get _locations => _db.collection('locations');

  static String? get uid {
    if (!_isFirebaseReady) return null;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  static Future<void> ensureSignedIn() async {
    if (!_isFirebaseReady) return;
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      final myUid = uid;
      if (myUid == null) return;

      final doc = await _users.doc(myUid).get();
      if (!doc.exists) {
        final code = await _generateUniqueFriendCode();
        await _users.doc(myUid).set({
          'nickname': '여행자${myUid.substring(0, 4).toUpperCase()}',
          'characterPath': 'assets/images/silla_hwarang_2head_cute.png',
          'friendCode': code,
          'stampCount': 0,
          'score': 0,
          'visitedSpots': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('UserService.ensureSignedIn Error: $e');
    }
  }

  static Future<String> _generateUniqueFriendCode() async {
    final rand = math.Random();
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = List.generate(6, (_) => _codeChars[rand.nextInt(_codeChars.length)]).join();
      final existing = await _users.where('friendCode', isEqualTo: code).limit(1).get();
      if (existing.docs.isEmpty) return code;
    }
    // 극히 드문 연속 충돌 시 타임스탬프 기반으로 유일성 보장
    return 'F${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>>? myProfileStream() {
    final myUid = uid;
    if (myUid == null) return null;
    return _users.doc(myUid).snapshots();
  }

  static Future<Map<String, dynamic>?> getProfile(String targetUid) async {
    if (!_isFirebaseReady) return null;
    try {
      final doc = await _users.doc(targetUid).get();
      return doc.data();
    } catch (e) {
      debugPrint('UserService.getProfile Error: $e');
      return null;
    }
  }

  static Future<void> updateProfile({String? nickname, String? characterPath}) async {
    final myUid = uid;
    if (myUid == null) return;
    final data = <String, dynamic>{};
    if (nickname != null && nickname.trim().isNotEmpty) data['nickname'] = nickname.trim();
    if (characterPath != null) data['characterPath'] = characterPath;
    if (data.isEmpty) return;
    try {
      await _users.doc(myUid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.updateProfile Error: $e');
    }
  }

  // 점수와 방문한 명소 목록을 Firestore에 저장해서, 앱을 재설치하거나 다른
  // 기기로 로그인해도 진행 상황이 이어지도록 한다. stampCount는 파티/친구
  // 목록 등에서 가볍게 보여주는 용도로 계속 별도 유지한다.
  static Future<void> updateProgress({required int score, required List<String> visitedSpots}) async {
    final myUid = uid;
    if (myUid == null) return;
    try {
      await _users.doc(myUid).set({
        'score': score,
        'stampCount': visitedSpots.length,
        'visitedSpots': visitedSpots,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.updateProgress Error: $e');
    }
  }

  // 여성안심/자녀안심 성격의 친구 위치 공유 기능. 기본값 OFF이며 사용자가
  // 설정 화면에서 명시적으로 켜야만 친구들에게 내 위치가 보인다.
  static Future<void> updateLocationSharing(bool enabled) async {
    final myUid = uid;
    if (myUid == null) return;
    try {
      await _locations.doc(myUid).set({'locationSharingEnabled': enabled}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.updateLocationSharing Error: $e');
    }
  }

  static Future<void> updateMyLocation(double lat, double lng) async {
    final myUid = uid;
    if (myUid == null) return;
    try {
      await _locations.doc(myUid).set({
        'lat': lat,
        'lng': lng,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.updateMyLocation Error: $e');
    }
  }

  static Future<bool> getLocationSharingEnabled() async {
    final myUid = uid;
    if (myUid == null) return false;
    try {
      final doc = await _locations.doc(myUid).get();
      return doc.data()?['locationSharingEnabled'] == true;
    } catch (e) {
      debugPrint('UserService.getLocationSharingEnabled Error: $e');
      return false;
    }
  }
}
