import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/friend_profile.dart';
import 'user_service.dart';

enum AddFriendResult { success, notFound, isSelf, alreadyFriends, notSignedIn, error }

class FriendService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _friendships => _db.collection('friendships');
  static CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  static CollectionReference<Map<String, dynamic>> get _locations => _db.collection('locations');

  static String _friendshipDocId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static Future<AddFriendResult> addFriendByCode(String rawCode) async {
    final myUid = UserService.uid;
    if (myUid == null) return AddFriendResult.notSignedIn;

    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return AddFriendResult.notFound;

    try {
      final query = await _users.where('friendCode', isEqualTo: code).limit(1).get();
      if (query.docs.isEmpty) return AddFriendResult.notFound;

      final targetUid = query.docs.first.id;
      if (targetUid == myUid) return AddFriendResult.isSelf;

      final docId = _friendshipDocId(myUid, targetUid);
      final existing = await _friendships.doc(docId).get();
      if (existing.exists) return AddFriendResult.alreadyFriends;

      await _friendships.doc(docId).set({
        'uids': [myUid, targetUid]..sort(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AddFriendResult.success;
    } catch (e) {
      debugPrint('FriendService.addFriendByCode Error: $e');
      return AddFriendResult.error;
    }
  }

  static Future<void> removeFriend(String friendUid) async {
    final myUid = UserService.uid;
    if (myUid == null) return;
    await _friendships.doc(_friendshipDocId(myUid, friendUid)).delete();
  }

  static Stream<List<FriendProfile>> watchFriends() {
    final myUid = UserService.uid;
    if (myUid == null) return const Stream.empty();

    return _friendships
        .where('uids', arrayContains: myUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final profiles = <FriendProfile>[];
      for (final doc in snapshot.docs) {
        final uids = List<String>.from(doc.data()['uids'] ?? []);
        final friendUid = uids.firstWhere((u) => u != myUid, orElse: () => '');
        if (friendUid.isEmpty) continue;

        final profileDoc = await _users.doc(friendUid).get();
        if (!profileDoc.exists) continue;

        final createdAt = doc.data()['createdAt'];
        profiles.add(FriendProfile.fromMap(
          friendUid,
          profileDoc.data()!,
          friendedAt: createdAt is Timestamp ? createdAt.toDate() : null,
        ));
      }
      return profiles;
    });
  }

  // 친구 한 명의 프로필(닉네임/캐릭터, 모두 읽기 가능한 users/{uid})과
  // 위치(locations/{uid}, 본인·실친구만 읽기 가능한 별도 컬렉션)를 합쳐서
  // 실시간으로 구독한다. locations 문서는 친구 관계가 아니면 firestore.rules에서
  // 권한 오류가 나므로, 그 경우 위치 없이 기본 프로필만 내려준다.
  static Stream<FriendProfile?> watchFriendProfile(String friendUid) {
    final controller = StreamController<FriendProfile?>.broadcast();
    Map<String, dynamic>? userData;
    Map<String, dynamic>? locationData;
    bool userLoaded = false;

    void emit() {
      if (!userLoaded) return;
      if (userData == null) {
        controller.add(null);
        return;
      }
      final merged = Map<String, dynamic>.from(userData!);
      if (locationData != null) merged.addAll(locationData!);
      controller.add(FriendProfile.fromMap(friendUid, merged));
    }

    final userSub = _users.doc(friendUid).snapshots().listen((doc) {
      userData = doc.exists ? doc.data() : null;
      userLoaded = true;
      emit();
    });
    final locationSub = _locations.doc(friendUid).snapshots().listen(
      (doc) {
        locationData = doc.exists ? doc.data() : null;
        emit();
      },
      onError: (_) {
        // 친구 관계가 아니어서 권한이 없는 경우 등 - 위치 없이 기본 프로필만 표시
        locationData = null;
        emit();
      },
    );

    controller.onCancel = () {
      userSub.cancel();
      locationSub.cancel();
    };

    return controller.stream;
  }
}
