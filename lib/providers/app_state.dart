import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/quest.dart';

class AppState extends ChangeNotifier {
  String _currentLanguage = 'ko';
  bool _isMapboxMode = false;
  int _score = 0;
  List<Map<String, dynamic>> _spotsData = [];
  String _selectedCharacterPath = 'assets/images/char_style1_male.png';

  double? _userLat;
  double? _userLng;

  final List<Quest> _quests = [
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
    
    // Update active quest target if needed
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest != null && activeQuest.currentTargetSpot == null) {
      _findNextTarget(activeQuest);
    }
  }

  void setActiveQuest(String questId) {
    // Deactivate all others
    for (var q in _quests) {
      q.isActive = false;
    }
    
    final quest = _quests.firstWhere((q) => q.id == questId);
    quest.isActive = true;
    _findNextTarget(quest);
    
    notifyListeners();
  }

  void _findNextTarget(Quest quest) {
    if (_userLat == null || _userLng == null || _spotsData.isEmpty) return;

    double minDistance = double.infinity;
    Map<String, dynamic>? bestSpot;

    for (var spot in _spotsData) {
      final title = spot['title'].toString();
      
      // Skip visited
      if (quest.visitedSpotTitles.contains(title)) continue;

      // Check keywords
      bool matches = false;
      final lowerTitle = title.toLowerCase();
      for (var kw in quest.keywords) {
        if (lowerTitle.contains(kw.toLowerCase())) {
          matches = true;
          break;
        }
      }

      if (matches) {
        double spotLat = double.tryParse(spot['mapY'].toString()) ?? 0;
        double spotLng = double.tryParse(spot['mapX'].toString()) ?? 0;
        
        double dist = _calculateDistance(_userLat!, _userLng!, spotLat, spotLng);
        if (dist < minDistance) {
          minDistance = dist;
          bestSpot = spot;
        }
      }
    }

    quest.currentTargetSpot = bestSpot;
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
  void markSpotVisited(String spotTitle) {
    bool updated = false;
    
    // Check if the visited spot was the target of an active planner quest
    final activeQuest = _quests.where((q) => q.isActive).firstOrNull;
    if (activeQuest != null) {
      if (activeQuest.currentTargetSpot != null && activeQuest.currentTargetSpot!['title'] == spotTitle) {
        activeQuest.addVisitedSpot(spotTitle);
        
        if (activeQuest.isCompleted) {
          addScore(activeQuest.rewardXP);
          activeQuest.isActive = false;
        } else {
          // Find next target
          _findNextTarget(activeQuest);
        }
        updated = true;
      }
    }

    if (updated) notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void toggleMapMode() {
    _isMapboxMode = !_isMapboxMode;
    notifyListeners();
  }

  void setCharacter(String path) {
    _selectedCharacterPath = path;
    notifyListeners();
  }
}
