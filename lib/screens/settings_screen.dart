import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locPermissionGranted = false;

  final List<Map<String, dynamic>> _illustrations = [
    {'path': 'assets/images/char_main.png', 'nameKey': 'char_main'},
    {'path': 'assets/images/char_king.png', 'nameKey': 'char_king'},
    {'path': 'assets/images/char_queen.png', 'nameKey': 'char_queen'},
    {'path': 'assets/images/char_hwarang.png', 'nameKey': 'char_hwarang'},
    {'path': 'assets/images/char_merchant.png', 'nameKey': 'char_merchant'},
    {'path': 'assets/images/char_princess.png', 'nameKey': 'char_princess'},
  ];

  final List<Map<String, dynamic>> _dotCharacters = [
    {'path': 'assets/images/char_style1_male.png', 'name': '도트 무사 (남)'},
    {'path': 'assets/images/char_style1_female.png', 'name': '도트 아씨 (여)'},
    {'path': 'assets/images/char_style2_male.png', 'name': '도트 도령 (남)'},
    {'path': 'assets/images/char_style2_female.png', 'name': '도트 낭자 (여)'},
  ];

  // Whether we are viewing 8-head or 2-head grid
  bool _isEightHeadMode = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (mounted) {
      setState(() {
        _locPermissionGranted = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
      });
    }
  }

  Future<void> _toggleLocationPermission(bool enable) async {
    if (enable) {
      LocationPermission permission = await Geolocator.requestPermission();
      setState(() {
        _locPermissionGranted = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
      });
    } else {
      await Geolocator.openLocationSettings();
      // Re-check after returning
      Future.delayed(const Duration(seconds: 1), _checkLocationPermission);
    }
  }

  void _showResetConfirmDialog(BuildContext context, AppState appState, String currentLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8D6E63), width: 2),
        ),
        title: Text(
          AppTranslations.get(currentLang, 'reset_progress'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Serif'),
        ),
        content: Text(
          AppTranslations.get(currentLang, 'reset_confirm'),
          style: const TextStyle(color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLang == 'ko' ? '취소' : 'Cancel',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              appState.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppTranslations.get(currentLang, 'reset_success')),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: Text(
              currentLang == 'ko' ? '초기화' : 'Reset',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentLang = appState.currentLanguage;

    final titleStr = AppTranslations.get(currentLang, 'settings');
    final locStr = AppTranslations.get(currentLang, 'loc_permission');
    final audioStr = AppTranslations.get(currentLang, 'audio_guide');
    final themeStr = AppTranslations.get(currentLang, 'theme_setting');
    final charStyleStr = AppTranslations.get(currentLang, 'char_style_setting');
    final langStr = AppTranslations.get(currentLang, 'language_setting');
    final resetStr = AppTranslations.get(currentLang, 'reset_progress');



    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hanji_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    Text(
                      titleStr,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF3E2723),
                        shadows: [
                          Shadow(color: Colors.white70, blurRadius: 2, offset: Offset(1, 1))
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                      child: Divider(color: Color(0xFF8D6E63), thickness: 2),
                    ),
                  ],
                ),
              ),

              // 1. Location Settings
              _buildSectionCard(
                title: locStr,
                icon: Icons.location_on,
                child: SwitchListTile(
                  title: Text(
                    _locPermissionGranted
                        ? AppTranslations.get(currentLang, 'loc_granted')
                        : AppTranslations.get(currentLang, 'loc_denied'),
                    style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.w600),
                  ),
                  value: _locPermissionGranted,
                  onChanged: _toggleLocationPermission,
                  activeColor: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Audio Settings
              _buildSectionCard(
                title: audioStr,
                icon: Icons.volume_up,
                child: SwitchListTile(
                  title: Text(
                    appState.audioEnabled
                        ? AppTranslations.get(currentLang, 'audio_enabled')
                        : AppTranslations.get(currentLang, 'audio_disabled'),
                    style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.w600),
                  ),
                  value: appState.audioEnabled,
                  onChanged: (val) => appState.setAudioEnabled(val),
                  activeColor: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Day / Night theme Mode
              _buildSectionCard(
                title: themeStr,
                icon: Icons.dark_mode,
                child: Column(
                  children: [
                    _buildThemeRadioTile(appState, 'auto', AppTranslations.get(currentLang, 'theme_auto')),
                    _buildThemeRadioTile(appState, 'day', AppTranslations.get(currentLang, 'theme_day')),
                    _buildThemeRadioTile(appState, 'night', AppTranslations.get(currentLang, 'theme_night')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Character Ratio Selection & Grid
              _buildSectionCard(
                title: charStyleStr,
                icon: Icons.face,
                child: Column(
                  children: [
                    // Segmented Selector
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(AppTranslations.get(currentLang, 'char_8_head')),
                            selected: _isEightHeadMode,
                            onSelected: (selected) {
                              if (selected) setState(() => _isEightHeadMode = true);
                            },
                            selectedColor: const Color(0xFFD4AF37),
                            labelStyle: TextStyle(
                              color: _isEightHeadMode ? Colors.white : const Color(0xFF8D6E63),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(AppTranslations.get(currentLang, 'char_2_head')),
                            selected: !_isEightHeadMode,
                            onSelected: (selected) {
                              if (selected) setState(() => _isEightHeadMode = false);
                            },
                            selectedColor: const Color(0xFFD4AF37),
                            labelStyle: TextStyle(
                              color: !_isEightHeadMode ? Colors.white : const Color(0xFF8D6E63),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Character Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _isEightHeadMode ? _illustrations.length : _dotCharacters.length,
                      itemBuilder: (context, index) {
                        final char = _isEightHeadMode ? _illustrations[index] : _dotCharacters[index];
                        final path = char['path'] as String;
                        final isSelected = appState.selectedCharacterPath == path;
                        final name = _isEightHeadMode
                            ? AppTranslations.get(currentLang, char['nameKey']!)
                            : char['name'] as String;

                        return GestureDetector(
                          onTap: () => appState.setCharacter(path),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFF3E0) : Colors.white70,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(path, fit: BoxFit.contain),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: const Color(0xFF3E2723),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Language Selection dropdown
              _buildSectionCard(
                title: langStr,
                icon: Icons.language,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: currentLang,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ko', child: Text('한국어 (Korean)')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ja', child: Text('日本語 (Japanese)')),
                      DropdownMenuItem(value: 'zh-chs', child: Text('简体中文 (Chinese)')),
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt (Vietnamese)')),
                      DropdownMenuItem(value: 'th', child: Text('ไทย (Thai)')),
                    ],
                    onChanged: (lang) {
                      if (lang != null) {
                        appState.setLanguage(lang);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. Reset Game Progress
              ElevatedButton.icon(
                onPressed: () => _showResetConfirmDialog(context, appState, currentLang),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  resetStr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF8D6E63)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Serif'),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFD7CCC8), indent: 16, endIndent: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildThemeRadioTile(AppState appState, String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037))),
      value: value,
      groupValue: appState.mapThemeMode,
      onChanged: (val) {
        if (val != null) appState.setMapThemeMode(val);
      },
      activeColor: const Color(0xFFD4AF37),
    );
  }
}
