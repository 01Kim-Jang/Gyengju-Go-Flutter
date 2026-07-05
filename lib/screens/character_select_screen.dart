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
      'id': 'char_main',
      'path': 'assets/images/char_main.png',
      'nameKey': 'char_main',
      'descKey': 'char_main_desc',
    },
    {
      'id': 'char_king',
      'path': 'assets/images/char_king.png',
      'nameKey': 'char_king',
      'descKey': 'char_king_desc',
    },
    {
      'id': 'char_queen',
      'path': 'assets/images/char_queen.png',
      'nameKey': 'char_queen',
      'descKey': 'char_queen_desc',
    },
    {
      'id': 'char_hwarang',
      'path': 'assets/images/char_hwarang.png',
      'nameKey': 'char_hwarang',
      'descKey': 'char_hwarang_desc',
    },
    {
      'id': 'char_merchant',
      'path': 'assets/images/char_merchant.png',
      'nameKey': 'char_merchant',
      'descKey': 'char_merchant_desc',
    },
    {
      'id': 'char_princess',
      'path': 'assets/images/char_princess.png',
      'nameKey': 'char_princess',
      'descKey': 'char_princess_desc',
    },
  ];

  String _selectedId = 'char_main';

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
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Taller ratio for 8-head characters
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
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(char['path'], fit: BoxFit.contain),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t[char['nameKey']] ?? char['nameKey'],
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: const Color(0xFF4A3B32),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    t[char['descKey']] ?? char['descKey'],
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
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
                child: Text(
                  lang == 'ko' ? '시작하기' : (lang == 'en' ? 'Start' : 'OK'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
