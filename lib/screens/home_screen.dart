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

          // AI 비서 버튼 (SafeArea 적용). 카카오맵/게임모드 어느 쪽이든 항상
          // 좌하단에 고정되도록 함.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
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
        onPressed: () {
          if (isMapActive) {
            _showMapModePicker(context, appState, lang);
          } else {
            appState.setCurrentTabIndex(1);
          }
        },
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

  void _showMapModePicker(BuildContext context, AppState appState, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                AppTranslations.get(lang, 'map_engine_setting'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F3864)),
              ),
              const SizedBox(height: 16),
              _mapModeOption(
                context: context,
                appState: appState,
                icon: Icons.layers,
                label: AppTranslations.get(lang, 'kakao_map_view'),
                selected: !appState.isMapboxMode,
                onTap: () {
                  if (appState.isMapboxMode) appState.toggleMapMode();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _mapModeOption(
                context: context,
                appState: appState,
                icon: Icons.map,
                label: AppTranslations.get(lang, 'mapbox_view'),
                selected: appState.isMapboxMode,
                onTap: () {
                  if (!appState.isMapboxMode) appState.toggleMapMode();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapModeOption({
    required BuildContext context,
    required AppState appState,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFFD4AF37) : const Color(0xFF8D6E63)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
          ],
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
