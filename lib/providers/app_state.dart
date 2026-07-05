import 'package:flutter/foundation.dart';
import '../models/quest.dart';

class AppState extends ChangeNotifier {
  String _currentLanguage = 'ko';
  bool _isMapboxMode = false;
  int _score = 0;
  List<Map<String, dynamic>> _spotsData = [];
  String _selectedCharacterPath = 'assets/images/char_style1_male.png';

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
  ];

  String get currentLanguage => _currentLanguage;
  bool get isMapboxMode => _isMapboxMode;
  int get score => _score;
  List<Map<String, dynamic>> get spotsData => _spotsData;
  List<Quest> get quests => _quests;
  String get selectedCharacterPath => _selectedCharacterPath;

  void setSpotsData(List<Map<String, dynamic>> spots) {
    _spotsData = spots;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void updateQuestProgress(String questId) {
    final quest = _quests.firstWhere((q) => q.id == questId, orElse: () => Quest(id: '', title: '', description: '', targetCount: 1, rewardXP: 0));
    if (quest.id.isNotEmpty && !quest.isCompleted) {
      quest.increment();
      if (quest.isCompleted) {
        addScore(quest.rewardXP);
      } else {
        notifyListeners();
      }
    }
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
