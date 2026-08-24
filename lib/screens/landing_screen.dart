import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import '../services/user_service.dart';
import '../utils/translations.dart';
import 'language_select_screen.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _dataLoaded = false;
  // 이미 온보딩(언어/캐릭터 선택)을 마친 적 있는 사용자로 확인되면, 언어 선택부터
  // 다시 거치지 않고 바로 홈 화면으로 들어간다.
  bool _isReturningUser = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      // 네비게이션은 이 애니메이션이 끝나고 데이터 로딩도 끝난 이후(둘 중 늦은 쪽)에
      // 발생하므로, 이 값이 곧 랜딩 화면의 최소 노출 시간이 된다. 데이터가 너무 빨리
      // 로드되면 화면이 순간적으로 지나가버리는 문제가 있어 2초로 늘렸다.
      duration: const Duration(seconds: 2),
    );

    // Start progress animation
    _progressController.forward();
    
    // Start prefetching data
    _prefetchData();
  }

  Future<void> _prefetchData() async {
    try {
      final appState = context.read<AppState>();

      // Firebase 준비가 안 됐거나 첫 실행이면 null이 돌아와서 기존 온보딩
      // 흐름(언어 선택부터)을 그대로 타므로 항상 안전하다. 네트워크가 느릴 때
      // 랜딩 화면이 무한정 멈춰있지 않도록 타임아웃을 둔다.
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
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
        _checkAndNavigate();
      }
    }
  }

  void _checkAndNavigate() {
    // If progress animation is done and data is loaded, navigate
    if (_progressController.isCompleted && _dataLoaded) {
      _navigateToNext();
    } else {
      // If data is loaded but animation isn't done, wait for animation
      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed && _dataLoaded && mounted) {
          _navigateToNext();
        }
      });
    }
  }

  void _navigateToNext() {
    final destination = _isReturningUser ? const HomeScreen() : const LanguageSelectScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<AppState>().currentLanguage;
    // 배경(baked) 이미지에 UI를 직접 굽던 기존 방식은 실제 진행바와 겹치는 문제가 있었어서,
    // 한지 텍스처 + 다크 사극풍 오버레이 + 캐릭터 PNG + 네이티브 텍스트/진행바를
    // 완전히 별도 레이어로 쌓는 방식으로 재구성했다.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hanji_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF3E2723).withValues(alpha: 0.88),
                const Color(0xFF2A1810).withValues(alpha: 0.94),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  'Gyeongju GO',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '(경주고)',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 6,
                  child: Image.asset(
                    'assets/images/char_main.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(flex: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0, left: 40, right: 40),
                  child: Column(
                    children: [
                      Text(
                        AppTranslations.get(currentLang, 'preparing_trip'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
