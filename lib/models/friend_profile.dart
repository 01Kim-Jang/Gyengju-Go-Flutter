class FriendProfile {
  final String uid;
  final String nickname;
  final String characterPath;
  final String friendCode;
  final int stampCount;
  final DateTime? friendedAt;

  FriendProfile({
    required this.uid,
    required this.nickname,
    required this.characterPath,
    required this.friendCode,
    this.stampCount = 0,
    this.friendedAt,
  });

  factory FriendProfile.fromMap(String uid, Map<String, dynamic> map, {DateTime? friendedAt}) {
    return FriendProfile(
      uid: uid,
      nickname: map['nickname']?.toString() ?? 'Traveler',
      characterPath: map['characterPath']?.toString() ??
          'assets/images/silla_hwarang_2head_cute.png',
      friendCode: map['friendCode']?.toString() ?? '',
      stampCount: (map['stampCount'] as num?)?.toInt() ?? 0,
      friendedAt: friendedAt,
    );
  }
}
