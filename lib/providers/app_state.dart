import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _currentLanguage = 'ko';
  bool _isMapboxMode = false;

  String get currentLanguage => _currentLanguage;
  bool get isMapboxMode => _isMapboxMode;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void toggleMapMode() {
    _isMapboxMode = !_isMapboxMode;
    notifyListeners();
  }
}
