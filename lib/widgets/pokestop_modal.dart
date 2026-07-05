import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/kakao_local_service.dart';
import '../utils/translations.dart';

class PokestopModal extends StatefulWidget {
  final Map<String, dynamic> spotData;

  const PokestopModal({super.key, required this.spotData});

  @override
  State<PokestopModal> createState() => _PokestopModalState();
}

class _PokestopModalState extends State<PokestopModal> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  double _rotationY = 0.0;
  bool _isSpun = false;
  bool _showScore = false;
  late AnimationController _spinController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreOpacity;
  late Animation<Offset> _scorePosition;

  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoadingPlaces = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );

    _spinController.addListener(() {
      setState(() {
        _rotationY = _spinController.value * 6 * math.pi; // Spin 3 times (Y axis)
      });
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isSpun) {
          setState(() {
            _isSpun = true;
          });
          _triggerScore();
          _playDocent();
          _fetchNearbyPlaces();
        }
      }
    });

    // Score Popup Animation
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scoreOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_scoreAnimationController);
    _scorePosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeOut));
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ko-KR");
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
    
    final places = await KakaoLocalService.fetchNearbyRestaurants(lat, lng);
    if (mounted) {
      setState(() {
        _restaurants = places;
        _isLoadingPlaces = false;
      });
    }
  }

  void _triggerScore() {
    setState(() { _showScore = true; });
    context.read<AppState>().addScore(50);
    context.read<AppState>().updateQuestProgress('spin_1');
    context.read<AppState>().updateQuestProgress('spin_5');
    
    _scoreAnimationController.forward(from: 0.0).then((_) {
      if (mounted) setState(() { _showScore = false; });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _spinController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSpun && !_spinController.isAnimating) {
      setState(() {
        _rotationY += details.delta.dx * 0.01;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isSpun && !_spinController.isAnimating) {
      if (details.velocity.pixelsPerSecond.dx.abs() > 300) {
        _spinController.forward(from: 0.0);
      }
    }
  }

  String _cleanTitle(String rawTitle) {
    String t = rawTitle;
    // Remove parentheses/brackets and their contents
    t = t.replaceAll(RegExp(r'\(.*?\)'), '');
    t = t.replaceAll(RegExp(r'（.*?）'), '');
    t = t.replaceAll(RegExp(r'\[.*?\]'), '');
    // Remove 'Gyeongju' prefixes in different languages
    t = t.replaceAll(RegExp(r'^경주\s*,?\s*'), '');
    t = t.replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'^慶州\s*,?\s*'), '');
    t = t.replaceAll(RegExp(r'^キョンジュ\s*,?\s*'), '');
    return t.trim();
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = widget.spotData['title'] ?? 'Pokestop';
    final title = _cleanTitle(rawTitle);
    final imageUrl = widget.spotData['firstimage'] ?? '';
    final overview = widget.spotData['overview'] ?? '';
    final localAssetPath = 'assets/images/spots/${title.replaceAll(' ', '_').replaceAll('/', '_')}.jpg';
    final currentLang = context.read<AppState>().currentLanguage;

    // 3D Matrix
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateY(_rotationY);

    // Is back of the coin showing? (Depends on rotation Y mod 2pi)
    bool isBack = (math.cos(_rotationY) < 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (!_isSpun) ...[
                const SizedBox(height: 10),
                Text(AppTranslations.get(currentLang, 'spin_hint'), style: const TextStyle(color: Colors.grey)),
              ],
              
              const SizedBox(height: 20),
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 8),
                      boxShadow: [
                        BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                      ],
                      color: Colors.white,
                    ),
                    child: isBack
                        ? Center(
                            child: Transform(
                              transform: Matrix4.rotationY(math.pi), // reverse the back text
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/pokeball.png', width: 100, errorBuilder: (c,e,s) => const Icon(Icons.star, size: 80, color: Colors.amber)),
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              localAssetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
                                  return Image.network(imageUrl, fit: BoxFit.cover);
                                }
                                return Container(color: Colors.grey[300], child: const Icon(Icons.museum, size: 50));
                              },
                            ),
                          ),
                  ),
                ),
              ),
              
              if (_isSpun)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(icon: const Icon(Icons.headset), text: AppTranslations.get(currentLang, 'docent_summary')),
                              Tab(icon: const Icon(Icons.restaurant), text: AppTranslations.get(currentLang, 'nearby_places')),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Docent Tab
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.volume_up, color: Colors.blue),
                                            const SizedBox(width: 10),
                                            Expanded(child: Text('$title ${AppTranslations.get(currentLang, 'docent_playing')}', style: const TextStyle(fontSize: 16, color: Colors.blue))),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(AppTranslations.get(currentLang, 'summary_desc'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 10),
                                      Text(overview.isNotEmpty ? overview.replaceAll('<br>', '\n').replaceAll(RegExp(r'<[^>]*>'), '') : '...', style: const TextStyle(fontSize: 15, height: 1.5)),
                                    ],
                                  ),
                                ),
                                // Places Tab
                                  _isLoadingPlaces
                                    ? const Center(child: CircularProgressIndicator())
                                    : _restaurants.isEmpty
                                        ? Center(child: Text(AppTranslations.get(currentLang, 'no_places')))
                                        : ListView.builder(
                                            itemCount: _restaurants.length,
                                            itemBuilder: (context, index) {
                                              final place = _restaurants[index];
                                              return ListTile(
                                                leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.restaurant, color: Colors.white)),
                                                title: Text(place['place_name'] ?? '식당'),
                                                subtitle: Text('${place['category_name']?.split('>').last?.trim()} | ${(double.parse(place['distance'] ?? '0') / 1000).toStringAsFixed(1)}km'),
                                                trailing: const Icon(Icons.chevron_right),
                                              );
                                            },
                                          ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Score Popup Overlay
          if (_showScore)
            SlideTransition(
              position: _scorePosition,
              child: FadeTransition(
                opacity: _scoreOpacity,
                child: Container(
                  margin: const EdgeInsets.only(top: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: const Text(
                    '+50 XP!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
