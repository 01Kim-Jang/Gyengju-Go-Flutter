import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
import 'home_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final List<Map<String, dynamic>> _characters = [
    {
      'id': 'style1_male',
      'path': 'assets/images/char_style1_male.png',
      'name': '깔끔한 남성',
      'desc': '단정한 한복을 입은 선비',
    },
    {
      'id': 'style1_female',
      'path': 'assets/images/char_style1_female.png',
      'name': '깔끔한 여성',
      'desc': '단아한 한복을 입은 여인',
    },
    {
      'id': 'style2_male',
      'path': 'assets/images/char_style2_male.png',
      'name': '도트 남성',
      'desc': '레트로 감성의 선비',
    },
    {
      'id': 'style2_female',
      'path': 'assets/images/char_style2_female.png',
      'name': '도트 여성',
      'desc': '레트로 감성의 여인',
    },
  ];

  String _selectedId = 'style1_male';

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().currentLanguage;
    final t = AppTranslations.translations[lang] ?? AppTranslations.translations['en']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              t['character_select'] ?? '캐릭터 선택',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF4A3B32),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t['character_select_desc'] ?? '함께 여행할 캐릭터를 선택해주세요.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _characters.length,
                itemBuilder: (context, index) {
                  final char = _characters[index];
                  final isSelected = _selectedId == char['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedId = char['id']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(char['path']),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  char['name'],
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: const Color(0xFF4A3B32),
                                  ),
                                ),
                                Text(
                                  char['desc'],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  final selectedPath = _characters.firstWhere((c) => c['id'] == _selectedId)['path'];
                  context.read<AppState>().setCharacter(selectedPath);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
