import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import '../services/user_service.dart';
import 'language_select_screen.dart';
import 'home_screen.dart';

/// 앱이 열릴 때 명소 데이터를 미리 받고, 기존 사용자면 온보딩을 건너뛰도록
/// 목적지를 정하는 화면. 예전에는 캐릭터/타이틀/진행바를 2초간 보여주는
/// 스플래시였지만, 준비가 끝나는 즉시 넘어가도록 바꾸고 화면은 다음 화면과
/// 같은 한지색 배경만 남겼다(색이 같아서 전환이 눈에 띄지 않는다).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // 이미 온보딩(언어/캐릭터 선택)을 마친 적 있는 사용자로 확인되면, 언어 선택부터
  // 다시 거치지 않고 바로 홈 화면으로 들어간다.
  bool _isReturningUser = false;

  @override
  void initState() {
    super.initState();
    _prefetchData();
  }

  Future<void> _prefetchData() async {
    try {
      final appState = context.read<AppState>();

      // Firebase 준비가 안 됐거나 첫 실행이면 null이 돌아와서 기존 온보딩
      // 흐름(언어 선택부터)을 그대로 타므로 항상 안전하다. 네트워크가 느릴 때
      // 화면이 무한정 멈춰있지 않도록 타임아웃을 둔다.
      Map<String, dynamic>? returningProfile;
      try {
        returningProfile = await UserService.getReturningUserProfile().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Returning-user check failed/timed out: $e");
      }

      String langForFetch = 'ko';
      if (returningProfile != null) {
        _isReturningUser = true;
        appState.applyReturningUserProfile(returningProfile);
        final savedLang = returningProfile['languagePreference']?.toString();
        if (savedLang != null && savedLang.isNotEmpty) langForFetch = savedLang;
      }

      final spots = await OdiiService.fetchGyeongjuSpots(langForFetch);
      if (mounted) {
        appState.setSpotsData(spots);
      }
    } catch (e) {
      debugPrint("Error prefetching spots: $e");
    } finally {
      if (mounted) _navigateToNext();
    }
  }

  void _navigateToNext() {
    final destination = _isReturningUser ? const HomeScreen() : const LanguageSelectScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 다음 화면들과 동일한 한지색. 로딩이 길어질 때만 잠깐 보인다.
    return const Scaffold(backgroundColor: Color(0xFFFDFBF7));
  }
}
