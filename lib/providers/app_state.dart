import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _currentLanguage = 'ko';
  bool _isMapboxMode = false;
  int _score = 0;

  String get currentLanguage => _currentLanguage;
  bool get isMapboxMode => _isMapboxMode;
  int get score => _score;

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void toggleMapMode() {
    _isMapboxMode = !_isMapboxMode;
    notifyListeners();
  }
}
