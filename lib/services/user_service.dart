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

  static Future<void> updateStampCount(int stampCount) async {
    final myUid = uid;
    if (myUid == null) return;
    try {
      await _users.doc(myUid).set({'stampCount': stampCount}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService.updateStampCount Error: $e');
    }
  }
}
