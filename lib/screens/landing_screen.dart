import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isLoading = false;

  Future<void> _selectLanguageAndLoad(String langCode) async {
    setState(() { _isLoading = true; });
    
    // Set language
    context.read<AppState>().setLanguage(langCode);
    
    // Pre-fetch spots data
    try {
      final spots = await OdiiService.fetchGyeongjuSpots(langCode);
      if (mounted) {
        context.read<AppState>().setSpotsData(spots);
      }
    } catch (e) {
      print("Error prefetching spots: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'zh-chs', 'name': '简体中文', 'flag': '🇨🇳'},
      {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
      {'code': 'th', 'name': 'ภาษาไทย', 'flag': '🇹🇭'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // 한지 느낌의 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.travel_explore,
              size: 100,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gyeongju GO',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF4A3B32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '천년의 역사를 거닐다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            const Text(
              '언어를 선택해주세요\nSelect your language',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: languages.map((lang) {
                return InkWell(
                  onTap: _isLoading ? null : () => _selectLanguageAndLoad(lang['code']!),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          lang['flag']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A3B32),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    SizedBox(height: 16),
                    Text('데이터를 불러오는 중입니다...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
