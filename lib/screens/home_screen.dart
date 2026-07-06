import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'kakao_map_view.dart';
import 'mapbox_view.dart';
import '../components/chatbot_sheet.dart';
import '../utils/translations.dart';
import 'quest_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // 기본은 가운데 '지도' 탭

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    // 네비게이션용 탭 내용
    final List<Widget> _pages = [
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
      const SettingsScreen(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFD4AF37),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: AppTranslations.get(lang, 'quest'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: AppTranslations.get(lang, 'map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppTranslations.get(lang, 'settings'),
          ),
        ],
      ),
    );
  }
}
