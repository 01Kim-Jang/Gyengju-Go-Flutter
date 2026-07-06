import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/kakao_local_service.dart';
import '../services/openai_service.dart';
import '../utils/translations.dart';
import '../data/spots_db.dart';
import '../models/quest.dart';

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
    
    // If already visited globally, consider it "spun" to show docent
    final title = _cleanTitle(widget.spotData['title'] ?? '');
    final appState = context.read<AppState>();
    if (appState.globalVisitedSpots.contains(title)) {
      _isSpun = true;
      _fetchNearbyPlaces();
    }
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
    final title = _cleanTitle(widget.spotData['title'] ?? '');
    final spotDetail = SpotsDB.get(title);
    final currentLang = context.read<AppState>().currentLanguage;
    
    String textToSpeak = '';
    if (spotDetail != null) {
      textToSpeak = "${spotDetail.getFact(currentLang)}. ${spotDetail.getTip(currentLang)}";
    } else {
      textToSpeak = widget.spotData['overview'] ?? '$title에 오신 것을 환영합니다.';
    }
    
    await flutterTts.speak(textToSpeak);
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

  void _startMatchingQuest(BuildContext context, String title) {
    final appState = context.read<AppState>();
    Quest? matchingQuest;
    for (var q in appState.quests) {
      if (q.type == 'planner') {
        for (var kw in q.keywords) {
          if (title.toLowerCase().contains(kw.toLowerCase())) {
            matchingQuest = q;
            break;
          }
        }
      }
      if (matchingQuest != null) break;
    }

    if (matchingQuest != null) {
      appState.setActiveQuest(matchingQuest.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.currentLanguage == 'ko'
                ? '${matchingQuest.title} 퀘스트가 시작되었습니다!'
                : 'Quest "${matchingQuest.title}" has started!',
          ),
          backgroundColor: const Color(0xFFD4AF37),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.currentLanguage == 'ko'
                ? '일치하는 테마 퀘스트가 없습니다. 퀘스트 탭에서 직접 선택해 보세요!'
                : 'No matching theme quest. Please select one in the Quest tab!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
    final spotDetail = SpotsDB.get(title);
    
    final imageUrl = spotDetail?.imagePath ?? widget.spotData['firstimage'] ?? '';
    final overview = widget.spotData['overview'] ?? '';
    
    final appState = context.watch<AppState>();
    final currentLang = appState.currentLanguage;
    final displayName = spotDetail != null ? spotDetail.getName(currentLang) : title;
    final hasStamp = appState.globalVisitedSpots.contains(title);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header Image with close button & Stamp status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: imageUrl.startsWith('assets/')
                      ? Image.asset(imageUrl, fit: BoxFit.cover)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.museum, size: 80, color: Colors.grey),
                          ),
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
              // Stamp Acquisition Status Banner
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasStamp 
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasStamp ? Colors.white : Colors.white30,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasStamp ? Icons.verified : Icons.stars,
                        color: hasStamp ? Colors.white : Colors.white60,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasStamp
                            ? (currentLang == 'ko' ? '스탬프 획득 완료' : 'STAMP COLLECTED')
                            : (currentLang == 'ko' ? '스탬프 미획득' : 'STAMP LOCKED'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
              displayName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Shortcut Buttons (Always visible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _playDocent,
                    icon: const Icon(Icons.volume_up, color: Color(0xFF4A90E2)),
                    label: Text(
                      AppTranslations.get(currentLang, 'play_docent'),
                      style: const TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF4A90E2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startMatchingQuest(context, title),
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: Text(
                      AppTranslations.get(currentLang, 'start_quest'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!_isSpun) ...[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                    Flexible(
                      child: Text(
                        AppTranslations.get(currentLang, 'spin_hint'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                                if (spotDetail != null) ...[
                                  Text(
                                    AppTranslations.get(currentLang, 'hist_facts'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    spotDetail.getFact(currentLang),
                                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppTranslations.get(currentLang, 'travel_tips'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    spotDetail.getTip(currentLang),
                                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                                  ),
                                ] else ...[
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
