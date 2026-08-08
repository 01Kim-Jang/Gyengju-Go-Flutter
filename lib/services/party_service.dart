import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/party.dart';
import 'user_service.dart';

enum JoinPartyResult { success, notFound, full, alreadyJoined, notSignedIn, error }

class JoinPartyOutcome {
  final JoinPartyResult result;
  final PartyModel? party;
  JoinPartyOutcome(this.result, this.party);
}

// Firestore parties/{partyId} 문서 기반 실시간 파티(함께하기) 동기화.
// members는 파티당 최대 6명 수준이라 서브컬렉션 대신 배열 필드로 저장하고
// 트랜잭션으로 read-modify-write 한다.
class PartyService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _parties => _db.collection('parties');

  static Future<String> _generateUniqueInviteCode() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = PartyModel.generateInviteCode();
      final existing = await _parties.where('inviteCode', isEqualTo: code).limit(1).get();
      if (existing.docs.isEmpty) return code;
    }
    return 'P${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
  }

  static PartyModel _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    return PartyModel.fromJson({...snap.data()!, 'partyId': snap.id});
  }

  // members(uid 목록)를 별도 배열 필드로도 저장해 Firestore 보안 규칙에서
  // "이 파티의 멤버인가"를 간단히 검사할 수 있게 한다 (배열-of-맵에서는 직접 조회 불가).
  static Map<String, dynamic> _membersPayload(List<PartyMember> members) {
    return {
      'members': members.map((m) => m.toJson()).toList(),
      'memberUids': members.map((m) => m.uid).toList(),
    };
  }

  static Future<PartyModel?> createParty({
    required String courseId,
    required String courseTitle,
    required String nickname,
    required String characterPath,
    required double lat,
    required double lng,
    required int stampCount,
  }) async {
    final myUid = UserService.uid;
    if (myUid == null) return null;

    final code = await _generateUniqueInviteCode();
    final docRef = _parties.doc();

    final host = PartyMember(
      uid: myUid,
      nickname: nickname,
      characterPath: characterPath,
      isHost: true,
      lat: lat,
      lng: lng,
      stampCount: stampCount,
    );

    final party = PartyModel(
      partyId: docRef.id,
      name: '$courseTitle 탐험대',
      inviteCode: code,
      courseId: courseId,
      courseTitle: courseTitle,
      members: [host],
    );

    await docRef.set({...party.toJson(), 'memberUids': [myUid]});
    return party;
  }

  static Future<JoinPartyOutcome> joinPartyByCode(
    String rawCode, {
    required String nickname,
    required String characterPath,
    required double lat,
    required double lng,
    required int stampCount,
  }) async {
    final myUid = UserService.uid;
    if (myUid == null) return JoinPartyOutcome(JoinPartyResult.notSignedIn, null);

    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return JoinPartyOutcome(JoinPartyResult.notFound, null);

    try {
      final query = await _parties.where('inviteCode', isEqualTo: code).limit(1).get();
      if (query.docs.isEmpty) return JoinPartyOutcome(JoinPartyResult.notFound, null);

      final docRef = query.docs.first.reference;
      PartyModel? updated;
      var result = JoinPartyResult.success;

      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          result = JoinPartyResult.notFound;
          return;
        }
        final current = _fromSnapshot(snap);

        if (current.members.any((m) => m.uid == myUid)) {
          updated = current;
          result = JoinPartyResult.alreadyJoined;
          return;
        }
        if (current.members.length >= current.maxMembers) {
          result = JoinPartyResult.full;
          return;
        }

        final me = PartyMember(
          uid: myUid,
          nickname: nickname,
          characterPath: characterPath,
          lat: lat,
          lng: lng,
          stampCount: stampCount,
        );

        final newMembers = [...current.members, me];
        tx.update(docRef, _membersPayload(newMembers));

        updated = PartyModel(
          partyId: current.partyId,
          name: current.name,
          inviteCode: current.inviteCode,
          courseId: current.courseId,
          courseTitle: current.courseTitle,
          members: newMembers,
          maxMembers: current.maxMembers,
          createdAt: current.createdAt,
          completionRatio: current.completionRatio,
        );
      });

      return JoinPartyOutcome(result, updated);
    } catch (e) {
      print('PartyService.joinPartyByCode Error: $e');
      return JoinPartyOutcome(JoinPartyResult.error, null);
    }
  }

  static Future<void> leaveParty(String partyId) async {
    final myUid = UserService.uid;
    if (myUid == null) return;
    final docRef = _parties.doc(partyId);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;
        final current = _fromSnapshot(snap);
        final leavingWasHost = current.members.any((m) => m.uid == myUid && m.isHost);
        var remaining = current.members.where((m) => m.uid != myUid).toList();

        if (remaining.isEmpty) {
          tx.delete(docRef);
          return;
        }
        if (leavingWasHost && !remaining.any((m) => m.isHost)) {
          remaining = [remaining.first.copyWith(isHost: true), ...remaining.skip(1)];
        }
        tx.update(docRef, _membersPayload(remaining));
      });
    } catch (e) {
      print('PartyService.leaveParty Error: $e');
    }
  }

  static Stream<PartyModel?> watchParty(String partyId) {
    return _parties.doc(partyId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return _fromSnapshot(snap);
    });
  }

  static Future<void> updateMemberProgress(
    String partyId, {
    required int stampCount,
    required double completionRatio,
  }) async {
    final myUid = UserService.uid;
    if (myUid == null) return;
    final docRef = _parties.doc(partyId);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;
        final current = _fromSnapshot(snap);
        final idx = current.members.indexWhere((m) => m.uid == myUid);
        if (idx == -1) return;
        current.members[idx].stampCount = stampCount;
        tx.update(docRef, {
          ..._membersPayload(current.members),
          'completionRatio': completionRatio.clamp(0.0, 1.0),
        });
      });
    } catch (e) {
      print('PartyService.updateMemberProgress Error: $e');
    }
  }

  static Future<void> updateMemberPosition(String partyId, double lat, double lng) async {
    final myUid = UserService.uid;
    if (myUid == null) return;
    final docRef = _parties.doc(partyId);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;
        final current = _fromSnapshot(snap);
        final idx = current.members.indexWhere((m) => m.uid == myUid);
        if (idx == -1) return;
        current.members[idx].lat = lat;
        current.members[idx].lng = lng;
        tx.update(docRef, _membersPayload(current.members));
      });
    } catch (e) {
      print('PartyService.updateMemberPosition Error: $e');
    }
  }
}
