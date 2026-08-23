import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
import 'home_screen.dart';

// 온보딩 마지막 단계(캐릭터 선택 이후) 또는 설정 화면에서 다시 볼 수 있는
// 간단한 사용법 튜토리얼. [fromSettings]가 true면 설정에서 다시 보기로
// 열린 것이므로 뒤로가기로 닫고, false면 온보딩 흐름이므로 홈 화면으로
// 넘어간다.
class TutorialScreen extends StatefulWidget {
  final bool fromSettings;
  const TutorialScreen({super.key, this.fromSettings = false});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    if (widget.fromSettings) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().currentLanguage;
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    AppTranslations.get(lang, 'tutorial_skip'),
                    style: const TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildSlide(
                    lang: lang,
                    imagePath: 'assets/images/char_main.png',
                    titleKey: 'tutorial_1_title',
                    descKey: 'tutorial_1_desc',
                  ),
                  _buildSlide(lang: lang, icon: Icons.explore, titleKey: 'tutorial_2_title', descKey: 'tutorial_2_desc'),
                  _buildSlide(lang: lang, icon: Icons.stars, titleKey: 'tutorial_3_title', descKey: 'tutorial_3_desc'),
                  _buildSlide(lang: lang, icon: Icons.diversity_3, titleKey: 'tutorial_4_title', descKey: 'tutorial_4_desc'),
                  _buildSlide(lang: lang, icon: Icons.health_and_safety, titleKey: 'tutorial_5_title', descKey: 'tutorial_5_desc'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFD4AF37) : const Color(0xFFD7CCC8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  AppTranslations.get(lang, isLastPage ? 'tutorial_start' : 'tutorial_next'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String lang,
    IconData? icon,
    String? imagePath,
    required String titleKey,
    required String descKey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            SizedBox(height: 220, child: Image.asset(imagePath, fit: BoxFit.contain))
          else
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 60),
            ),
          const SizedBox(height: 32),
          Text(
            AppTranslations.get(lang, titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 12),
          Text(
            AppTranslations.get(lang, descKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7D5A50), height: 1.5),
          ),
        ],
      ),
    );
  }
}
