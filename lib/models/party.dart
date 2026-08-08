import 'dart:math' as math;

class PartyMember {
  final String uid;
  final String nickname;
  final String characterPath;
  final bool isHost;
  double lat;
  double lng;
  int stampCount;
  String status; // 'active', 'ready', 'completed'

  PartyMember({
    required this.uid,
    required this.nickname,
    required this.characterPath,
    this.isHost = false,
    required this.lat,
    required this.lng,
    this.stampCount = 0,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nickname': nickname,
        'characterPath': characterPath,
        'isHost': isHost,
        'lat': lat,
        'lng': lng,
        'stampCount': stampCount,
        'status': status,
      };

  PartyMember copyWith({bool? isHost}) => PartyMember(
        uid: uid,
        nickname: nickname,
        characterPath: characterPath,
        isHost: isHost ?? this.isHost,
        lat: lat,
        lng: lng,
        stampCount: stampCount,
        status: status,
      );

  factory PartyMember.fromJson(Map<String, dynamic> json) => PartyMember(
        uid: json['uid'] ?? '',
        nickname: json['nickname'] ?? 'Traveler',
        characterPath: json['characterPath'] ?? 'assets/images/silla_hwarang_2head_cute.png',
        isHost: json['isHost'] ?? false,
        lat: (json['lat'] as num?)?.toDouble() ?? 35.8348,
        lng: (json['lng'] as num?)?.toDouble() ?? 129.2266,
        stampCount: json['stampCount'] ?? 0,
        status: json['status'] ?? 'active',
      );
}

class PartyModel {
  final String partyId;
  final String name;
  final String inviteCode; // 8-digit uppercase code (e.g. SIL8K9A2)
  final String courseId;
  final String courseTitle;
  final List<PartyMember> members;
  final int maxMembers;
  final DateTime createdAt;
  double completionRatio;

  PartyModel({
    required this.partyId,
    required this.name,
    required this.inviteCode,
    required this.courseId,
    required this.courseTitle,
    required this.members,
    this.maxMembers = 6,
    DateTime? createdAt,
    this.completionRatio = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();

  static String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = math.Random();
    return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> toJson() => {
        'partyId': partyId,
        'name': name,
        'inviteCode': inviteCode,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'members': members.map((m) => m.toJson()).toList(),
        'maxMembers': maxMembers,
        'createdAt': createdAt.toIso8601String(),
        'completionRatio': completionRatio,
      };

  factory PartyModel.fromJson(Map<String, dynamic> json) => PartyModel(
        partyId: json['partyId'] ?? '',
        name: json['name'] ?? '신라 파티',
        inviteCode: json['inviteCode'] ?? 'SIL8K9A2',
        courseId: json['courseId'] ?? 'c_royal',
        courseTitle: json['courseTitle'] ?? 'C-ROYAL: 신라 왕실 핵심 탐방',
        members: (json['members'] as List<dynamic>?)
                ?.map((m) => PartyMember.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        maxMembers: json['maxMembers'] ?? 6,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        completionRatio: (json['completionRatio'] as num?)?.toDouble() ?? 0.0,
      );
}
