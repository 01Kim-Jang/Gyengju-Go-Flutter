import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quest.dart';
import '../models/party.dart';
import '../services/odii_service.dart';
import '../services/user_service.dart';
import '../services/party_service.dart';
import '../services/tago_service.dart';
import '../services/friend_service.dart';
import '../services/trip_log_service.dart';
import '../models/friend_profile.dart';
import '../data/spots_db.dart';
import '../services/notification_service.dart';
import '../utils/translations.dart';

class AppState extends ChangeNotifier {
  String _currentLanguage = 'ko';
  // 앱의 정체성인 게이미피케이션 경험(포켓스탑, 스탬프, 캐릭터)을 첫 화면부터
  // 바로 보여주기 위해 게임모드(Mapbox)를 기본값으로 시작한다.
  bool _isMapboxMode = true;
  int _score = 0;
  List<Map<String, dynamic>> _spotsData = [];
  String _selectedCharacterPath = 'assets/images/char_style1_male.png';
  final Set<String> _globalVisitedSpots = {};
  // 세션 동안 "근처에 새 스탬프가 있어요" 알림을 이미 보낸 명소 (같은 곳 근처를
  // 서성일 때마다 반복 알림이 뜨지 않도록 방지). 앱 재시작 시 초기화되는 걸로 충분하다.
  final Set<String> _notifiedNearbySpots = {};
  static const double _nearbyNotificationRadiusM = 150.0;
  bool _audioEnabled = true;
  String _mapThemeMode = 'auto'; // 'auto', 'day', 'night'

  double? _userLat;
  double? _userLng;

  List<List<double>> _routeCoordinates = [];
  List<List<double>> get routeCoordinates => _routeCoordinates;

  // 도보 내비게이션 실시간 갱신 스로틀링 (매 GPS 틱마다 Directions API를 호출하지 않도록)
  DateTime? _lastRouteFetchTime;
  double? _lastRouteFetchLat;
  double? _lastRouteFetchLng;

  // 여행 보고서(일지)용 이동 궤적 기록. 앱이 켜져 있는 동안(포그라운드) 일정
  // 거리/시간 간격으로 좌표를 로컬에 저장해서, 나중에 그날 실제로 걸은 경로를
  // 지도에 다시 그릴 수 있게 한다.
  double? _lastBreadcrumbLat;
  double? _lastBreadcrumbLng;
  DateTime? _lastBreadcrumbTime;

  // 대중교통 정류소 접근 알림 (필요할 때만, 즉 감시 활성화 후 정류소에 실제로
  // 가까워졌을 때 한 번만 튀어나오도록 설계됨)
  bool _transitAlertActive = false;
  bool get transitAlertActive => _transitAlertActive;
  bool _isCheckingTransitStop = false;
  DateTime? _lastTransitCheckTime;
  double? _lastTransitCheckLat;
  double? _lastTransitCheckLng;
  NearestStopArrivals? _pendingTransitAlert;
  NearestStopArrivals? get pendingTransitAlert => _pendingTransitAlert;

  String _navigationMode = 'walk'; // 'walk' or 'drive'
  String get navigationMode => _navigationMode;

  bool _isFetchingRoute = false;
  bool get isFetchingRoute => _isFetchingRoute;

  int _currentTabIndex = 1; // Default to Map tab (index 1)
  int get currentTabIndex => _currentTabIndex;

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- User Profile (Firebase) ---
  String _myNickname = '여행자';
  String get myNickname => _myNickname;
  String? _myFriendCode;
  String? get myFriendCode => _myFriendCode;

  bool _progressRestored = false;

  Future<void> loadMyProfile() async {
    await UserService.ensureSignedIn();
    final uid = UserService.uid;
    if (uid == null) return;
    final profile = await UserService.getProfile(uid);
    if (profile != null) {
      _myFriendCode = profile['friendCode']?.toString();
      _myNickname = profile['nickname']?.toString() ?? _myNickname;

      // 저장된 점수·방문 스탬프를 앱 시작 시 딱 한 번만 복원한다. loadMyProfile()은
      // Firebase 초기화 재시도 때문에 여러 번 호출될 수 있는데, 그때마다 복원하면
      // 그사이 사용자가 새로 쌓은 진행 상황을 예전 값으로 덮어쓰게 되기 때문이다.
      if (!_progressRestored) {
        _progressRestored = true;
        final savedScore = (profile['score'] as num?)?.toInt();
        final savedVisited = (profile['visitedSpots'] as List?)?.map((e) => e.toString()).toList();
        if (savedScore != null) _score = savedScore;
        if (savedVisited != null) {
          _globalVisitedSpots
            ..clear()
            ..addAll(savedVisited);
        }
      }
    }
    _locationSharingEnabled = await UserService.getLocationSharingEnabled();
    notifyListeners();
    startWatchingFriends();
  }

  Future<void> updateNickname(String nickname) async {
    if (nickname.trim().isEmpty) return;
    _myNickname = nickname.trim();
    notifyListeners();
    await UserService.updateProfile(nickname: _myNickname);
  }

  // --- 친구 위치 공유 (여성안심/자녀안심 성격의 안전 기능) ---
  // 전체 친구에게 한 번에 ON/OFF 하는 전역 토글이며, 기본값은 OFF다.
  // 앱이 켜져 있는 동안(포그라운드)에만 위치가 갱신되어 친구들에게 보인다.
  bool _locationSharingEnabled = false;
  bool get locationSharingEnabled => _locationSharingEnabled;
  double? _lastSharedLat;
  double? _lastSharedLng;

  Future<void> toggleLocationSharing(bool enabled) async {
    _locationSharingEnabled = enabled;
    notifyListeners();
    await UserService.updateLocationSharing(enabled);
    if (enabled && _userLat != null && _userLng != null) {
      await UserService.updateMyLocation(_userLat!, _userLng!);
    }
  }

  StreamSubscription<List<FriendProfile>>? _friendsListSub;
  final Map<String, StreamSubscription<FriendProfile?>> _friendLocationSubs = {};
  final Map<String, FriendProfile> _friendLocations = {};

  // 위치 공유를 켜둔 친구들만 (게임모드 지도에 캐릭터+이름표로 표시됨)
  List<FriendProfile> get sharingFriends => _friendLocations.values
      .where((f) => f.locationSharingEnabled && f.lat != null && f.lng != null)
      .toList();

  void startWatchingFriends() {
    _friendsListSub?.cancel();
    _friendsListSub = FriendService.watchFriends().listen((friends) {
      final currentUids = friends.map((f) => f.uid).toSet();

      // 더 이상 친구가 아니게 된 uid의 구독은 정리
      final toRemove = _friendLocationSubs.keys.where((u) => !currentUids.contains(u)).toList();
      for (final u in toRemove) {
        _friendLocationSubs.remove(u)?.cancel();
        _friendLocations.remove(u);
      }

      // 새로 추가된 친구에 대해서만 실시간 위치 구독 시작
      for (final uid in currentUids) {
        if (_friendLocationSubs.containsKey(uid)) continue;
        _friendLocationSubs[uid] = FriendService.watchFriendProfile(uid).listen((profile) {
          if (profile == null) {
            _friendLocations.remove(uid);
          } else {
            _friendLocations[uid] = profile;
          }
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }

  // --- Party (Co-Op Travel) Management — Firestore 실시간 동기화 ---
  PartyModel? _activeParty;
  PartyModel? get activeParty => _activeParty;
  List<PartyMember> get partyMembers => _activeParty?.members ?? [];
  bool _isPartyBusy = false;
  bool get isPartyBusy => _isPartyBusy;
  StreamSubscription<PartyModel?>? _partySub;
  double? _lastPartySyncedLat;
  double? _lastPartySyncedLng;

  Future<PartyModel?> createParty({required String courseId, required String courseTitle}) async {
    await UserService.ensureSignedIn();
    if (UserService.uid == null) return null;

    _isPartyBusy = true;
    notifyListeners();
    final party = await PartyService.createParty(
      courseId: courseId,
      courseTitle: courseTitle,
      nickname: _myNickname,
      characterPath: _selectedCharacterPath,
      lat: _userLat ?? 35.8348,
      lng: _userLng ?? 129.2266,
      stampCount: _globalVisitedSpots.length,
    );
    _isPartyBusy = false;

    if (party != null) {
      _bindActiveParty(party);
      setActiveQuest(courseId);
    } else {
      notifyListeners();
    }
    return party;
  }

  Future<JoinPartyResult> joinParty(String code) async {
    await UserService.ensureSignedIn();
    if (UserService.uid == null) return JoinPartyResult.notSignedIn;

    _isPartyBusy = true;
    notifyListeners();
    final outcome = await PartyService.joinPartyByCode(
      code,
      nickname: _myNickname,
      characterPath: _selectedCharacterPath,
      lat: _userLat ?? 35.8348,
      lng: _userLng ?? 129.2266,
      stampCount: _globalVisitedSpots.length,
    );
    _isPartyBusy = false;

    if (outcome.party != null) {
      _bindActiveParty(outcome.party!);
      setActiveQuest(outcome.party!.courseId);
    } else {
      notifyListeners();
    }
    return outcome.result;
  }

  void _bindActiveParty(PartyModel party) {
    _activeParty = party;
    _partySub?.cancel();
    _partySub = PartyService.watchParty(party.partyId).listen((updated) {
      _activeParty = updated;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> leaveParty() async {
    final party = _activeParty;
    _partySub?.cancel();
    _partySub = null;
    _activeParty = null;
    notifyListeners();
    if (party != null) {
      await PartyService.leaveParty(party.partyId);
    }
  }

  @override
  void dispose() {
    _partySub?.cancel();
    _friendsListSub?.cancel();
    for (final sub in _friendLocationSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }

  final List<Quest> _quests = [
    // --- 3 MVP Core Courses (PRD Specification) ---
    Quest(
      id: 'c_royal',
      title: 'C-ROYAL: 신라 왕실 핵심 탐방',
      description: '대릉원, 첨성대, 계림, 월성, 동궁과 월지를 거니는 도보 중심 왕실 탐방 코스',
      targetCount: 4,
      rewardXP: 300,
      type: 'planner',
      keywords: ['대릉원', '첨성대', '계림', '월성', '동궁과 월지', 'daereungwon', 'cheomseongdae', 'gyerim', 'wolseong', 'donggung'],
    ),
    Quest(
      id: 'c_buddha',
      title: 'C-BUDDHA: 명작 불교문화 탐방',
      description: '불국사, 석굴암, 괘릉을 방문하는 천년 불교 예술 버스 탐방 코스',
      targetCount: 2,
      rewardXP: 300,
      type: 'planner',
      keywords: ['불국사', '석굴암', '괘릉', 'bulguksa', 'seokguram', 'gwaereung'],
    ),
    Quest(
      id: 'c_munmu',
      title: 'C-MUNMU: 동해 호국 용의 길',
      description: '감은사지, 이견대, 문무대왕릉을 둘러보는 동해 드라이브 호국 탐방 코스',
      targetCount: 3,
      rewardXP: 300,
      type: 'planner',
      keywords: ['감은사지', '이견대', '문무대왕릉', 'gameunsa', 'igyeondae', 'munmu'],
    ),
    Quest(
      id: 'spin_1',
      title: '첫 걸음',
      description: '포켓스탑을 처음으로 스핀하여 도슨트를 들어보세요.',
      targetCount: 1,
      rewardXP: 100,
    ),
    Quest(
      id: 'spin_5',
      title: '신라의 발자취',
      description: '포켓스탑을 5회 스핀하세요.',
      targetCount: 5,
      rewardXP: 500,
    ),
    // Planner Quests
    Quest(
      id: 'planner_tomb',
      title: '신라 왕릉 탐방',
      description: '천년의 잠이 든 왕릉들을 찾아가 보세요.',
      targetCount: 5,
      rewardXP: 1000,
      type: 'planner',
      keywords: ['릉', '총', '묘', '고분', 'tomb'],
    ),
    Quest(
      id: 'planner_temple',
      title: '천년의 사찰 순례',
      description: '아름다운 사찰과 불교 문화를 체험하세요.',
      targetCount: 5,
      rewardXP: 1000,
      type: 'planner',
      keywords: ['사', '암', '절', 'temple', '사지'],
    ),
    Quest(
      id: 'planner_historic',
      title: '역사 유적지 산책',
      description: '궁궐 터와 유적지를 거닐며 옛 신라를 느껴보세요.',
      targetCount: 5,
      rewardXP: 1000,
      type: 'planner',
      keywords: ['궁', '지', '유적', '산성', '대', 'palace', 'site', 'pavilion'],
    ),
    Quest(
      id: 'planner_art',
      title: '신라의 예술과 문화',
      description: '박물관과 미술관에서 신라의 찬란한 예술을 감상하세요.',
      targetCount: 3,
      rewardXP: 800,
      type: 'planner',
      keywords: ['박물관', '전시관', '예술', '미술', 'museum', 'art', 'exhibition'],
    ),
    Quest(
      id: 'planner_nature',
      title: '자연과 휴식',
      description: '자연 속에서 평온한 휴식을 즐겨보세요.',
      targetCount: 3,
      rewardXP: 800,
      type: 'planner',
      keywords: ['공원', '숲', '산', '호수', '바위', 'park', 'forest', 'mountain', 'lake'],
    ),
    Quest(
      id: 'planner_hwangridan',
      title: '황리단길 핫플 탐험',
      description: '요즘 가장 핫한 황리단길의 감성을 느껴보세요.',
      targetCount: 3,
      rewardXP: 800,
      type: 'planner',
      keywords: ['황리단길', '마을', '거리', 'hwangridan-gil', 'village', 'street'],
    ),
  ];

  String get currentLanguage => _currentLanguage;
  bool get isMapboxMode => _isMapboxMode;
  int get score => _score;
  List<Map<String, dynamic>> get spotsData => _spotsData;
  List<Quest> get quests => _quests;
  String get selectedCharacterPath => _selectedCharacterPath;
  Set<String> get globalVisitedSpots => _globalVisitedSpots;
  bool get audioEnabled => _audioEnabled;
  String get mapThemeMode => _mapThemeMode;

  bool get isNightMode {
    if (_mapThemeMode == 'night') return true;
    if (_mapThemeMode == 'day') return false;
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  double? get userLat => _userLat;
  double? get userLng => _userLng;

  void setSpotsData(List<Map<String, dynamic>> spots) {
    _spotsData = spots;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void updateUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;

    // Sync position to active party (throttled to movements > ~10m to limit writes)
    if (_activeParty != null) {
      final movedFar = _lastPartySyncedLat == null ||
          _calculateDistance(_lastPartySyncedLat!, _lastPartySyncedLng!, lat, lng) * 1000 > 10;
      if (movedFar) {
        _lastPartySyncedLat = lat;
        _lastPartySyncedLng = lng;
        PartyService.updateMemberPosition(_activeParty!.partyId, lat, lng);
      }
    }

    // 여행 보고서용 궤적 기록 (30m 이상 이동 + 45초 이상 경과 시에만, 저장 용량/빈도 절약)
    final breadcrumbNow = DateTime.now();
    final movedFarForBreadcrumb = _lastBreadcrumbLat == null ||
        _calculateDistance(_lastBreadcrumbLat!, _lastBreadcrumbLng!, lat, lng) * 1000 > 30;
    final breadcrumbTimePassed = _lastBreadcrumbTime == null ||
        breadcrumbNow.difference(_lastBreadcrumbTime!) > const Duration(seconds: 45);
    if (movedFarForBreadcrumb && breadcrumbTimePassed) {
      _lastBreadcrumbLat = lat;
      _lastBreadcrumbLng = lng;
      _lastBreadcrumbTime = breadcrumbNow;
      TripLogService.appendBreadcrumb(lat, lng, at: breadcrumbNow);
    }

    // 친구 위치 공유가 켜져 있으면 동일한 방식으로(10m 이상 이동 시) 내 위치를 갱신
    if (_locationSharingEnabled) {
      final movedFarForFriends = _lastSharedLat == null ||
          _calculateDistance(_lastSharedLat!, _lastSharedLng!, lat, lng) * 1000 > 10;
      if (movedFarForFriends) {
        _lastSharedLat = lat;
        _lastSharedLng = lng;
        UserService.updateMyLocation(lat, lng);
      }
    }

    // Update active quest target if needed (GPS가 늦게 잡혀서 계획이 아직 없는 경우에만 재계산)
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest != null) {
      if (activeQuest.plannedOrder.isEmpty && activeQuest.currentTargetSpot == null) {
        _planQuestRoute(activeQuest);
      }

      // 도보 내비게이션 중 목적지에 도착(25m 이내)하면 경로를 자동으로 종료한다.
      final target = activeQuest.currentTargetSpot;
      if (_navigationMode == 'walk' && target != null && _routeCoordinates.isNotEmpty && getDistanceToSpot(target) <= 25.0) {
        clearRoute();
        return;
      }

      // 매 GPS 틱마다 Directions API를 부르지 않도록, 일정 거리(20m) 이상 이동했고
      // 마지막 호출로부터 일정 시간(8초)이 지났을 때만 경로를 다시 계산해서
      // "실시간으로 따라오는" 트래킹 경험을 과도한 API 호출 없이 구현한다.
      final now = DateTime.now();
      final movedFar = _lastRouteFetchLat == null ||
          _calculateDistance(_lastRouteFetchLat!, _lastRouteFetchLng!, lat, lng) * 1000 > 20;
      final enoughTimePassed = _lastRouteFetchTime == null ||
          now.difference(_lastRouteFetchTime!) > const Duration(seconds: 8);
      if (movedFar && enoughTimePassed) {
        _lastRouteFetchLat = lat;
        _lastRouteFetchLng = lng;
        _lastRouteFetchTime = now;
        triggerRouteFetch();
      }
    }

    if (_transitAlertActive) {
      _maybeCheckTransitProximity(lat, lng);
    }

    _maybeNotifyNearbyStamp(lat, lng);
  }

  // 아직 방문하지 않은 명소가 근처(150m 이내)에 있으면 로컬 알림을 한 번 보낸다.
  // 같은 명소에 대해 세션 중 반복 알림은 보내지 않는다.
  void _maybeNotifyNearbyStamp(double lat, double lng) {
    for (final spot in _spotsData) {
      final title = spot['title']?.toString() ?? '';
      if (title.isEmpty) continue;
      if (_globalVisitedSpots.contains(title)) continue;
      if (_notifiedNearbySpots.contains(title)) continue;

      final spotLat = double.tryParse(spot['mapY']?.toString() ?? '');
      final spotLng = double.tryParse(spot['mapX']?.toString() ?? '');
      if (spotLat == null || spotLng == null) continue;

      final distM = _calculateDistance(lat, lng, spotLat, spotLng) * 1000.0;
      if (distM > _nearbyNotificationRadiusM) continue;

      _notifiedNearbySpots.add(title);
      final displayName = SpotsDB.get(title)?.getName(_currentLanguage) ?? title;
      final suffix = AppTranslations.get(_currentLanguage, 'nearby_stamp_body_suffix');
      NotificationService.showNearbyStamp(
        title: AppTranslations.get(_currentLanguage, 'nearby_stamp_title'),
        body: '$displayName$suffix',
      );
    }
  }

  void startTransitAlert() {
    _transitAlertActive = true;
  }

  void clearTransitAlert() {
    _pendingTransitAlert = null;
    notifyListeners();
  }

  Future<void> _maybeCheckTransitProximity(double lat, double lng) async {
    if (_isCheckingTransitStop) return;

    final now = DateTime.now();
    final movedFar = _lastTransitCheckLat == null ||
        _calculateDistance(_lastTransitCheckLat!, _lastTransitCheckLng!, lat, lng) * 1000 > 15;
    final enoughTimePassed = _lastTransitCheckTime == null ||
        now.difference(_lastTransitCheckTime!) > const Duration(seconds: 10);
    if (!movedFar || !enoughTimePassed) return;

    _lastTransitCheckLat = lat;
    _lastTransitCheckLng = lng;
    _lastTransitCheckTime = now;
    _isCheckingTransitStop = true;
    try {
      final stops = await TagoService.fetchNearbyStops(lat, lng);
      if (stops.isEmpty) return;
      final nearest = stops.first;
      if (nearest.distanceM <= 40.0) {
        final arrivals = await TagoService.fetchArrivals(nearest.cityCode, nearest.nodeId);
        _pendingTransitAlert = NearestStopArrivals(stop: nearest, arrivals: arrivals);
        // 한 번 알린 뒤에는 감시를 자동으로 종료한다 (정류장을 지나칠 때마다
        // 계속 튀어나오는 것이 아니라 "필요할 때만" 한 번 뜨도록).
        _transitAlertActive = false;
        notifyListeners();
      }
    } finally {
      _isCheckingTransitStop = false;
    }
  }

  void setActiveQuest(String questId) {
    // Deactivate all others
    for (var q in _quests) {
      q.isActive = false;
    }

    final quest = _quests.firstWhere((q) => q.id == questId);
    quest.isActive = true;
    _planQuestRoute(quest);

    triggerRouteFetch();
    notifyListeners();
  }

  // 진행 중인 퀘스트를 완료 처리 없이 중도에 그만둔다. 네비게이션(경로 표시)이
  // 켜져 있어도 언제든 끌 수 있도록 경로/타겟 배너를 함께 초기화한다.
  void cancelActiveQuest() {
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest == null) return;
    activeQuest.isActive = false;
    clearRoute();
  }

  // 퀘스트 키워드에 매칭되면서 아직 방문하지 않은 명소 목록
  List<Map<String, dynamic>> _matchingUnvisitedSpots(Quest quest) {
    final results = <Map<String, dynamic>>[];
    for (var spot in _spotsData) {
      final title = spot['title'].toString();
      if (quest.visitedSpotTitles.contains(title)) continue;

      bool matches = false;
      final spotDetail = SpotsDB.get(title);
      final List<String> searchTexts = [
        title.toLowerCase(),
        if (spotDetail != null) ...[
          spotDetail.names['ko']?.toLowerCase() ?? '',
          spotDetail.names['en']?.toLowerCase() ?? '',
        ]
      ];

      for (var kw in quest.keywords) {
        for (var text in searchTexts) {
          if (text.contains(kw.toLowerCase())) {
            matches = true;
            break;
          }
        }
        if (matches) break;
      }

      if (matches) results.add(spot);
    }
    return results;
  }

  // 현재 위치에서 출발해 남은 목적지들을 총 이동거리가 최소가 되는 순서로 정렬한다.
  // 지점 수가 적으므로(최대 targetCount, 실사용상 ≤5) 완전탐색으로 최적해를 구하고,
  // 혹시 더 많아지는 경우를 대비해 최근접 이웃 탐욕법으로 폴백한다.
  List<Map<String, dynamic>> _computeOptimalOrder(
    List<Map<String, dynamic>> spots,
    double startLat,
    double startLng,
  ) {
    if (spots.length <= 1) return spots;

    if (spots.length > 7) {
      final remaining = List<Map<String, dynamic>>.from(spots);
      final ordered = <Map<String, dynamic>>[];
      double curLat = startLat, curLng = startLng;
      while (remaining.isNotEmpty) {
        remaining.sort((a, b) {
          final da = _calculateDistance(curLat, curLng,
              double.tryParse(a['mapY'].toString()) ?? 0, double.tryParse(a['mapX'].toString()) ?? 0);
          final db = _calculateDistance(curLat, curLng,
              double.tryParse(b['mapY'].toString()) ?? 0, double.tryParse(b['mapX'].toString()) ?? 0);
          return da.compareTo(db);
        });
        final next = remaining.removeAt(0);
        ordered.add(next);
        curLat = double.tryParse(next['mapY'].toString()) ?? curLat;
        curLng = double.tryParse(next['mapX'].toString()) ?? curLng;
      }
      return ordered;
    }

    final permutations = <List<Map<String, dynamic>>>[];
    void permute(List<Map<String, dynamic>> pool, List<Map<String, dynamic>> acc) {
      if (pool.isEmpty) {
        permutations.add(List.from(acc));
        return;
      }
      for (var i = 0; i < pool.length; i++) {
        final next = List<Map<String, dynamic>>.from(pool)..removeAt(i);
        permute(next, [...acc, pool[i]]);
      }
    }

    permute(spots, []);

    double bestDistance = double.infinity;
    List<Map<String, dynamic>> bestOrder = spots;
    for (final perm in permutations) {
      double total = 0;
      double curLat = startLat, curLng = startLng;
      for (final spot in perm) {
        final lat = double.tryParse(spot['mapY'].toString()) ?? curLat;
        final lng = double.tryParse(spot['mapX'].toString()) ?? curLng;
        total += _calculateDistance(curLat, curLng, lat, lng);
        curLat = lat;
        curLng = lng;
      }
      if (total < bestDistance) {
        bestDistance = total;
        bestOrder = perm;
      }
    }
    return bestOrder;
  }

  // 퀘스트의 방문 순서(plannedOrder)를 현재 위치 기준으로 새로 계산하고 다음 목적지를 설정한다.
  void _planQuestRoute(Quest quest) {
    final remainingSlots = quest.targetCount - quest.currentCount;
    if (remainingSlots <= 0 || _spotsData.isEmpty) {
      quest.plannedOrder = [];
      quest.currentTargetSpot = null;
      return;
    }

    var matching = _matchingUnvisitedSpots(quest);
    final startLat = _userLat ?? 35.8348;
    final startLng = _userLng ?? 129.2266;

    if (matching.length > remainingSlots) {
      matching.sort((a, b) {
        final da = _calculateDistance(startLat, startLng,
            double.tryParse(a['mapY'].toString()) ?? 0, double.tryParse(a['mapX'].toString()) ?? 0);
        final db = _calculateDistance(startLat, startLng,
            double.tryParse(b['mapY'].toString()) ?? 0, double.tryParse(b['mapX'].toString()) ?? 0);
        return da.compareTo(db);
      });
      matching = matching.take(remainingSlots).toList();
    }

    final ordered = _computeOptimalOrder(matching, startLat, startLng);
    quest.plannedOrder = ordered.map((s) => s['title'].toString()).toList();
    quest.currentTargetSpot = ordered.isNotEmpty ? ordered.first : null;
  }

  // 50m Geofencing helpers
  double getDistanceToSpot(Map<String, dynamic> spot) {
    if (_userLat == null || _userLng == null) return 0.0;
    double spotLat = double.tryParse(spot['mapY'].toString()) ?? 0.0;
    double spotLng = double.tryParse(spot['mapX'].toString()) ?? 0.0;
    if (spotLat == 0.0 || spotLng == 0.0) return 0.0;
    return _calculateDistance(_userLat!, _userLng!, spotLat, spotLng) * 1000.0; // returns in meters
  }

  bool isSpotWithin50m(Map<String, dynamic> spot) {
    if (_userLat == null || _userLng == null) return true; // Default fallback to allow in mock/sim mode
    double distInMeters = getDistanceToSpot(spot);
    return distInMeters <= 50.0;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  void updateQuestProgress(String questId) {
    final quest = _quests.firstWhere((q) => q.id == questId, orElse: () => _quests.first);
    if (quest.id == questId && !quest.isCompleted) {
      quest.increment();
      if (quest.isCompleted) {
        addScore(quest.rewardXP);
        if (quest.isActive) {
          quest.isActive = false;
        }
      }
      notifyListeners();
    }
  }

  // New method specifically for planner spot spin
  void markSpotVisited(String spotTitle, {double? lat, double? lng}) {
    bool updated = false;

    // Always add to global stamp book
    if (!_globalVisitedSpots.contains(spotTitle)) {
      _globalVisitedSpots.add(spotTitle);
      updated = true;
    }

    // 여행 보고서용 방문 기록 (로컬 저장, 날짜별로 쌓임)
    if (lat != null && lng != null) {
      TripLogService.appendVisit(spotTitle, lat, lng);
    }
    
    // Check if the visited spot is part of the active quest's planned route.
    // (계획된 순서와 다르게 먼저 방문하더라도 체크리스트에 반영되도록 순서 무관하게 인정)
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest != null) {
      final isPlannedSpot = activeQuest.plannedOrder.contains(spotTitle) ||
          (activeQuest.currentTargetSpot != null && activeQuest.currentTargetSpot!['title'] == spotTitle);
      if (isPlannedSpot && !activeQuest.visitedSpotTitles.contains(spotTitle)) {
        activeQuest.addVisitedSpot(spotTitle);

        if (activeQuest.isCompleted) {
          addScore(activeQuest.rewardXP);
          activeQuest.isActive = false;
          clearRoute();
        } else {
          final nextTitle = activeQuest.plannedOrder.firstWhere(
            (t) => !activeQuest.visitedSpotTitles.contains(t),
            orElse: () => '',
          );
          if (nextTitle.isNotEmpty) {
            activeQuest.currentTargetSpot =
                _spotsData.where((s) => s['title'].toString() == nextTitle).firstOrNull;
          } else {
            // 계획된 지점을 모두 방문했지만 아직 목표치가 안 찼다면(키워드 기반 퀘스트) 재계획
            _planQuestRoute(activeQuest);
          }
          triggerRouteFetch();
        }
        updated = true;
      }
    }

    // Sync progress to Firestore (user profile + active party, if any) so it
    // survives app reinstalls / device switches instead of living only in memory.
    UserService.updateProgress(score: _score, visitedSpots: _globalVisitedSpots.toList());
    if (_activeParty != null) {
      final courseQuest = _quests.firstWhere(
        (q) => q.id == _activeParty!.courseId,
        orElse: () => _quests.first,
      );
      final ratio = courseQuest.targetCount > 0
          ? (_globalVisitedSpots.length / courseQuest.targetCount).clamp(0.0, 1.0)
          : 0.0;
      PartyService.updateMemberProgress(
        _activeParty!.partyId,
        stampCount: _globalVisitedSpots.length,
        completionRatio: ratio,
      );
    }

    if (updated) notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    try {
      final loadedSpots = await OdiiService.fetchGyeongjuSpots(lang);
      if (loadedSpots.isNotEmpty) {
        _spotsData = loadedSpots;
      }
    } catch (e) {
      debugPrint("Error fetching spots in new language: $e");
    }
    notifyListeners();
    // 언어 선택 최초 화면과 설정 화면 언어 변경 둘 다 이 메서드를 거치므로,
    // 여기 한 곳에서만 저장해도 두 경로 모두 커버된다.
    UserService.updateProfile(languagePreference: lang);
  }

  // 랜딩 화면에서 이미 온보딩을 마친 재방문 사용자로 확인됐을 때, 저장된
  // 언어/캐릭터/닉네임을 로컬 상태에 반영한다. 스팟 데이터는 호출한 쪽에서
  // 해당 언어로 다시 불러와야 한다(이 메서드는 fetch를 하지 않는다).
  void applyReturningUserProfile(Map<String, dynamic> profile) {
    final lang = profile['languagePreference']?.toString();
    if (lang != null && lang.isNotEmpty) _currentLanguage = lang;
    final characterPath = profile['characterPath']?.toString();
    if (characterPath != null && characterPath.isNotEmpty) _selectedCharacterPath = characterPath;
    final nickname = profile['nickname']?.toString();
    if (nickname != null && nickname.isNotEmpty) _myNickname = nickname;
    notifyListeners();
  }

  void setAudioEnabled(bool val) {
    _audioEnabled = val;
    notifyListeners();
  }

  void setMapThemeMode(String mode) {
    _mapThemeMode = mode;
    notifyListeners();
  }

  void resetProgress() {
    _score = 0;
    _globalVisitedSpots.clear();
    _routeCoordinates.clear();
    for (var q in _quests) {
      q.currentCount = 0;
      q.isActive = false;
      q.visitedSpotTitles.clear();
      q.currentTargetSpot = null;
    }
    UserService.updateProgress(score: 0, visitedSpots: []);
    notifyListeners();
  }

  void toggleMapMode() {
    _isMapboxMode = !_isMapboxMode;
    notifyListeners();
  }

  void setNavigationMode(String mode) {
    _navigationMode = mode;
    notifyListeners();
    triggerRouteFetch();
  }

  void clearRoute() {
    _routeCoordinates.clear();
    notifyListeners();
  }

  Future<void> triggerRouteFetch() async {
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest == null || activeQuest.currentTargetSpot == null) {
      clearRoute();
      return;
    }
    final spot = activeQuest.currentTargetSpot!;
    final double endLat = double.tryParse(spot['mapY'].toString()) ?? 0;
    final double endLng = double.tryParse(spot['mapX'].toString()) ?? 0;
    if (endLat == 0 || endLng == 0 || _userLat == null || _userLng == null) {
      clearRoute();
      return;
    }
    await fetchRoutePoints(_userLat!, _userLng!, endLat, endLng);
  }

  Future<void> fetchRoutePoints(double startLat, double startLng, double endLat, double endLng) async {
    if (_isFetchingRoute) return; // Prevent concurrent duplicate fetches
    _isFetchingRoute = true;
    notifyListeners();

    try {
      final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
      if (token.isEmpty) {
        debugPrint('Mapbox access token is empty. Cannot fetch route.');
        _routeCoordinates.clear();
        return;
      }
      
      final profile = _navigationMode == 'drive' ? 'driving' : 'walking';
      final url = 'https://api.mapbox.com/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat?geometries=geojson&access_token=$token';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'] as Map;
          final coordinates = geometry['coordinates'] as List;
          
          _routeCoordinates = coordinates.map<List<double>>((coordsList) {
            return [
              double.parse(coordsList[0].toString()), // Lng
              double.parse(coordsList[1].toString()), // Lat
            ];
          }).toList();
        } else {
          _routeCoordinates.clear();
        }
      } else {
        debugPrint('Mapbox Directions API Error: ${response.statusCode}');
        _routeCoordinates.clear();
      }
    } catch (e) {
      debugPrint('Error fetching route points: $e');
      _routeCoordinates.clear();
    } finally {
      _isFetchingRoute = false;
      notifyListeners();
    }
  }

  void setCharacter(String path) {
    _selectedCharacterPath = path;
    notifyListeners();
    UserService.updateProfile(characterPath: path);
  }
}
