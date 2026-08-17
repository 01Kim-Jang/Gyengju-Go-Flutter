import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'kakao_map_view.dart';
import 'mapbox_view.dart';
import '../components/chatbot_sheet.dart';
import '../utils/translations.dart';
import 'quest_screen.dart';
import 'party_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    // 네비게이션용 탭 내용 (지도가 하단바 중앙의 원형 버튼으로 항상 고정되도록,
    // Quest(0) / Map(1) / Social(2) / Settings(3) 순서를 유지한다.
    final List<Widget> pages = [
      const QuestScreen(),
      // 지도 화면 탭
      Stack(
        children: [
          IndexedStack(
            index: appState.isMapboxMode ? 1 : 0,
            children: const [KakaoMapView(), MapboxView()],
          ),

          // AI 비서 버튼 (SafeArea 적용). 지도 엔진 전환은 설정 화면으로 이동해
          // 퀘스트 내비게이션 배너를 가리지 않도록 함.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  heroTag: "aiChatbot",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ChatBotSheet(),
                    );
                  },
                  backgroundColor: Colors.white,
                  icon: const Icon(
                    Icons.support_agent,
                    color: Color(0xFFD4AF37),
                    size: 32,
                  ),
                  label: Text(
                    AppTranslations.get(lang, 'ai_assistant'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const PartyScreen(),
      const SettingsScreen(),
    ];

    final safeTabIndex = appState.currentTabIndex.clamp(0, pages.length - 1);
    final isMapActive = safeTabIndex == 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (appState.currentTabIndex != 0) {
          appState.setCurrentTabIndex(0);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.get(lang, 'press_back_again_to_exit')),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      body: pages[safeTabIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "mapTabButton",
        onPressed: () => appState.setCurrentTabIndex(1),
        backgroundColor: isMapActive ? const Color(0xFFD4AF37) : Colors.white,
        elevation: 4,
        shape: CircleBorder(
          side: BorderSide(
            color: const Color(0xFFD4AF37),
            width: isMapActive ? 0 : 2,
          ),
        ),
        child: Icon(
          Icons.map,
          color: isMapActive ? Colors.white : const Color(0xFFD4AF37),
          size: 26,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildNavItem(appState, 0, Icons.explore, AppTranslations.get(lang, 'quest')),
                  _buildNavItem(appState, 2, Icons.diversity_3, AppTranslations.get(lang, 'social')),
                ],
              ),
              _buildNavItem(appState, 3, Icons.settings, AppTranslations.get(lang, 'settings')),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildNavItem(AppState appState, int index, IconData icon, String label) {
    final isSelected = appState.currentTabIndex == index;
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.grey[600];
    return InkWell(
      onTap: () => appState.setCurrentTabIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
