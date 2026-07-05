import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import 'character_select_screen.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  bool _isLoading = false;

  final List<Map<String, String>> languages = [
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'zh-chs', 'name': '简体中文', 'flag': '🇨🇳'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'th', 'name': 'ภาษาไทย', 'flag': '🇹🇭'},
  ];

  Future<void> _selectLanguageAndLoad(String langCode) async {
    setState(() { _isLoading = true; });
    
    // Set language
    context.read<AppState>().setLanguage(langCode);
    
    // If not Korean (which was fetched in Landing), fetch new language POIs
    if (langCode != 'ko') {
      try {
        final spots = await OdiiService.fetchGyeongjuSpots(langCode);
        if (mounted) {
          context.read<AppState>().setSpotsData(spots);
        }
      } catch (e) {
        print("Error fetching language spots: $e");
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CharacterSelectScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hanji_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                '언어를 선택해주세요\nSelect your language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B32),
                ),
              ),
              const SizedBox(height: 48),
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
                            color: Colors.black.withValues(alpha: 0.05),
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
              const Spacer(),
              if (_isLoading) ...[
                const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                const Text('언어 데이터를 적용하는 중입니다...', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
