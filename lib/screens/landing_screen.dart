import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import '../utils/translations.dart';
import 'language_select_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Base animation duration
    );

    // Start progress animation
    _progressController.forward();
    
    // Start prefetching data
    _prefetchData();
  }

  Future<void> _prefetchData() async {
    try {
      // Fetch default 'ko' data
      final spots = await OdiiService.fetchGyeongjuSpots('ko');
      if (mounted) {
        context.read<AppState>().setSpotsData(spots);
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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LanguageSelectScreen(),
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
