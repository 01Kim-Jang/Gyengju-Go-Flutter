import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/kakao_local_service.dart';
import '../services/openai_service.dart';
import '../utils/translations.dart';

class PokestopModal extends StatefulWidget {
  final Map<String, dynamic> spotData;

  const PokestopModal({super.key, required this.spotData});

  @override
  State<PokestopModal> createState() => _PokestopModalState();
}

class _PokestopModalState extends State<PokestopModal> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  bool _isSpun = false;
  bool _showScore = false;
  
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoadingPlaces = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    final lang = context.read<AppState>().currentLanguage;
    String ttsLang = "ko-KR";
    if (lang == 'en') ttsLang = "en-US";
    if (lang == 'ja') ttsLang = "ja-JP";
    if (lang == 'zh-chs') ttsLang = "zh-CN";
    
    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _playDocent() async {
    final title = widget.spotData['title'] ?? '유적지';
    final desc = widget.spotData['overview'] ?? '$title에 오신 것을 환영합니다.';
    await flutterTts.speak(desc);
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() { _isLoadingPlaces = true; });
    double lat = double.tryParse(widget.spotData['mapY'].toString()) ?? 35.8348;
    double lng = double.tryParse(widget.spotData['mapX'].toString()) ?? 129.2266;
    
    var places = await KakaoLocalService.fetchNearbyRestaurants(lat, lng);
    
    if (mounted) {
      final currentLang = context.read<AppState>().currentLanguage;
      if (currentLang != 'ko' && places.isNotEmpty) {
        places = await OpenAIService.translateRestaurants(places, currentLang);
      }
    }

    if (mounted) {
      setState(() {
        _restaurants = places;
        _isLoadingPlaces = false;
      });
    }
  }

  void _triggerSpin() {
    setState(() { _isSpun = true; _showScore = true; });
    
    final appState = context.read<AppState>();
    appState.addScore(50);
    appState.updateQuestProgress('spin_1');
    appState.updateQuestProgress('spin_5');
    
    final title = _cleanTitle(widget.spotData['title'] ?? '');
    appState.markSpotVisited(title);

    _playDocent();
    _fetchNearbyPlaces();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _showScore = false; });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  String _cleanTitle(String rawTitle) {
    String t = rawTitle;
    t = t.replaceAll(RegExp(r'\([^)]*\)'), '');
    t = t.replaceAll(RegExp(r'\[[^\]]*\]'), '');
    t = t.replaceAll(RegExp(r'^경주\s*,?\s*'), '');
    t = t.replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '');
    return t.trim();
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = widget.spotData['title'] ?? 'Pokestop';
    final title = _cleanTitle(rawTitle);
    final imageUrl = widget.spotData['firstimage'] ?? '';
    final overview = widget.spotData['overview'] ?? '';
    final localAssetPath = 'assets/images/spots/${title.replaceAll(' ', '_').replaceAll('/', '_')}.jpg';
    final currentLang = context.watch<AppState>().currentLanguage;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header Image with close button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.asset(
                    localAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
                        return Image.network(imageUrl, fit: BoxFit.cover);
                      }
                      return Container(color: Colors.grey[300], child: const Icon(Icons.museum, size: 80, color: Colors.grey));
                    },
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
              // Score Animation Overlay
              if (_showScore)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Text(
                      '+50 XP',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          if (!_isSpun) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _triggerSpin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      AppTranslations.get(currentLang, 'spin_hint'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ] else ...[
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: const Color(0xFF4A90E2),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF4A90E2),
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.headset), 
                          text: AppTranslations.get(currentLang, 'docent_summary')
                        ),
                        Tab(
                          icon: const Icon(Icons.restaurant), 
                          text: AppTranslations.get(currentLang, 'nearby_places')
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Docent Tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.volume_up, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppTranslations.get(currentLang, 'docent_playing'),
                                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppTranslations.get(currentLang, 'summary_desc'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  overview,
                                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          // Restaurants Tab
                          _isLoadingPlaces
                            ? const Center(child: CircularProgressIndicator())
                            : _restaurants.isEmpty
                                ? Center(child: Text(AppTranslations.get(currentLang, 'no_places')))
                                : ListView.separated(
                                    itemCount: _restaurants.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final place = _restaurants[index];
                                      String distStr = '';
                                      if (place['distance'] != null) {
                                        int meters = int.tryParse(place['distance'].toString()) ?? 0;
                                        distStr = '${(meters / 1000).toStringAsFixed(1)}km';
                                      }
                                      
                                      String catName = place['category_name']?.toString() ?? '';
                                      List<String> catParts = catName.split('>');
                                      String shortCat = catParts.isNotEmpty ? catParts.last.trim() : catName;

                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.orange[100],
                                          child: const Icon(Icons.restaurant, color: Colors.orange),
                                        ),
                                        title: Text(
                                          place['place_name'] ?? 'Unknown',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text('$shortCat | $distStr'),
                                        trailing: const Icon(Icons.chevron_right),
                                        onTap: () {},
                                      );
                                    },
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
