class FriendProfile {
  final String uid;
  final String nickname;
  final String characterPath;
  final String friendCode;
  final int stampCount;
  final DateTime? friendedAt;
  // 여성안심/자녀안심 성격의 위치 공유 기능용 필드. 친구가 위치 공유를 켜둔
  // 경우에만 lat/lng가 채워지며, 게임모드 지도에 캐릭터+이름표로 표시된다.
  final double? lat;
  final double? lng;
  final bool locationSharingEnabled;

  FriendProfile({
    required this.uid,
    required this.nickname,
    required this.characterPath,
    required this.friendCode,
    this.stampCount = 0,
    this.friendedAt,
    this.lat,
    this.lng,
    this.locationSharingEnabled = false,
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
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      locationSharingEnabled: map['locationSharingEnabled'] == true,
    );
  }
}
