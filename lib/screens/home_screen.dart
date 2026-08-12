import 'package:flutter/material.dart';
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

          // 모드 전환 토글 버튼 및 AI 비서 버튼 (SafeArea 적용)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "mapToggle",
                    onPressed: () {
                      context.read<AppState>().toggleMapMode();
                    },
                    backgroundColor: appState.isMapboxMode
                        ? const Color(0xFFD4AF37) // 사극풍 골드/브라운
                        : Colors.white,
                    icon: Icon(
                      appState.isMapboxMode ? Icons.map : Icons.layers,
                      color: appState.isMapboxMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    label: Text(
                      appState.isMapboxMode
                          ? AppTranslations.get(lang, 'kakao_map_view')
                          : AppTranslations.get(lang, 'mapbox_view'),
                      style: TextStyle(
                        color: appState.isMapboxMode
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FloatingActionButton.extended(
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
                ],
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

    return Scaffold(
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
