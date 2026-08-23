import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
import '../utils/marker_generator.dart';
import '../services/trip_log_service.dart';
import '../data/spots_db.dart';

// 스탬프북 전용 화면. 이전에는 6개 랜드마크로 고정된 작은 팝업이었지만,
// 앱에 실제로 있는 명소 전체를 반영하고, 실제 랜드마크 이미지를 스탬프
// 디자인으로 쓰고, 여행 보고서 방문 기록을 이용해 방문 시각을 보여주고,
// 눌러서 상세를 볼 수 있고, 다 모았을 때 이미지로 공유할 수 있게 확장했다.
class StampBookScreen extends StatefulWidget {
  const StampBookScreen({super.key});

  @override
  State<StampBookScreen> createState() => _StampBookScreenState();
}

class _StampBookScreenState extends State<StampBookScreen> {
  final GlobalKey _captureKey = GlobalKey();
  Map<String, TripVisit> _firstVisitByTitle = {};
  bool _loadingVisits = true;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final all = await TripLogService.getAllVisits();
    final map = <String, TripVisit>{};
    for (final v in all) {
      final clean = _cleanTitle(v.spotTitle);
      // getAllVisits()는 시간순 정렬되어 있으므로 처음 만난 값이 최초 방문이다.
      map.putIfAbsent(clean, () => v);
    }
    if (mounted) {
      setState(() {
        _firstVisitByTitle = map;
        _loadingVisits = false;
      });
    }
  }

  String _cleanTitle(String rawTitle) {
    return rawTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
        .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
        .trim();
  }

  String _resolveImage(Map<String, dynamic> spot) {
    final local = MarkerGenerator.getLocalImagePath(
      spot['title']?.toString() ?? '',
      mapX: spot['mapX']?.toString(),
      mapY: spot['mapY']?.toString(),
    );
    return local ?? spot['firstimage']?.toString() ?? '';
  }

  Future<void> _shareStampBook(String lang) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/gyeongju_go_stamp_book.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: AppTranslations.get(lang, 'stamp_book_share_text'),
        ),
      );
    } catch (e) {
      debugPrint('Stamp book share error: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _onTapStamp(Map<String, dynamic> spot, String lang, bool isCollected) {
    final title = _cleanTitle(spot['title']?.toString() ?? '');
    if (!isCollected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get(lang, 'stamp_locked'))),
      );
      return;
    }
    final spotDetail = SpotsDB.get(title);
    final visit = _firstVisitByTitle[title];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StampDetailSheet(
        title: spotDetail != null ? spotDetail.getName(lang) : title,
        imageUrl: _resolveImage(spot),
        fact: spotDetail?.getFact(lang),
        tip: spotDetail?.getTip(lang),
        visit: visit,
        lang: lang,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    // 실제 앱에 있는 명소 전체를 스탬프북 목록으로 사용 (제목 중복 제거).
    final Map<String, Map<String, dynamic>> uniqueSpots = {};
    for (final spot in appState.spotsData) {
      final clean = _cleanTitle(spot['title']?.toString() ?? '');
      if (clean.isEmpty) continue;
      uniqueSpots.putIfAbsent(clean, () => spot);
    }
    final spots = uniqueSpots.entries.toList();
    final collectedCount = spots.where((e) => appState.globalVisitedSpots.contains(e.key)).length;
    final isComplete = spots.isNotEmpty && collectedCount == spots.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'stamp_book')),
        backgroundColor: const Color(0xFFFDFBF7),
        foregroundColor: const Color(0xFF3E2723),
        elevation: 1,
        actions: [
          IconButton(
            icon: _sharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share),
            onPressed: _sharing ? null : () => _shareStampBook(lang),
            tooltip: AppTranslations.get(lang, 'share_stamp_book'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hanji_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: RepaintBoundary(
            key: _captureKey,
            child: Container(
              color: const Color(0xFFF9F6F0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      children: [
                        Text(
                          '${AppTranslations.get(lang, 'collected')}: $collectedCount / ${spots.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
                        ),
                        if (isComplete) ...[
                          const SizedBox(height: 6),
                          Text(
                            AppTranslations.get(lang, 'stamp_book_complete'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loadingVisits
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 18,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: spots.length,
                            itemBuilder: (context, index) {
                              final entry = spots[index];
                              final title = entry.key;
                              final spot = entry.value;
                              final isCollected = appState.globalVisitedSpots.contains(title);
                              final imageUrl = _resolveImage(spot);
                              final spotDetail = SpotsDB.get(title);
                              final displayName = spotDetail != null ? spotDetail.getName(lang) : title;

                              return GestureDetector(
                                onTap: () => _onTapStamp(spot, lang, isCollected),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isCollected ? const Color(0xFFD4AF37) : Colors.grey[400]!,
                                              width: 2.5,
                                            ),
                                            boxShadow: isCollected
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.orange.withValues(alpha: 0.25),
                                                      blurRadius: 6,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: ClipOval(
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                if (imageUrl.isNotEmpty)
                                                  imageUrl.startsWith('assets/')
                                                      ? Image.asset(imageUrl, fit: BoxFit.cover)
                                                      : Image.network(
                                                          imageUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (c, e, s) => Container(
                                                            color: Colors.grey[300],
                                                            child: const Icon(Icons.museum, color: Colors.grey),
                                                          ),
                                                        )
                                                else
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons.museum, color: Colors.grey),
                                                  ),
                                                // 미획득 명소는 흑백 처리 + 자물쇠 오버레이로 "아직 못 모았다"는 느낌을 준다.
                                                if (!isCollected)
                                                  ColorFiltered(
                                                    colorFilter: const ColorFilter.matrix(<double>[
                                                      0.2126, 0.7152, 0.0722, 0, 0,
                                                      0.2126, 0.7152, 0.0722, 0, 0,
                                                      0.2126, 0.7152, 0.0722, 0, 0,
                                                      0, 0, 0, 1, 0,
                                                    ]),
                                                    child: Container(color: Colors.black.withValues(alpha: 0.45)),
                                                  ),
                                                if (!isCollected)
                                                  const Center(
                                                    child: Icon(Icons.lock, color: Colors.white, size: 26),
                                                  ),
                                                if (isCollected)
                                                  Positioned(
                                                    right: 2,
                                                    bottom: 2,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 18),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isCollected ? FontWeight.bold : FontWeight.normal,
                                        color: isCollected ? const Color(0xFF3E2723) : Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StampDetailSheet extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? fact;
  final String? tip;
  final TripVisit? visit;
  final String lang;

  const _StampDetailSheet({
    required this.title,
    required this.imageUrl,
    required this.fact,
    required this.tip,
    required this.visit,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl.startsWith('assets/')
                      ? Image.asset(imageUrl, fit: BoxFit.cover)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                        ),
                ),
              ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (visit != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event_available, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  Text(
                    '${AppTranslations.get(lang, 'visited_on')}: ${_formatDate(visit!.timestamp)}',
                    style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (fact != null && fact!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(AppTranslations.get(lang, 'hist_facts'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
              const SizedBox(height: 6),
              Text(fact!, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
            if (tip != null && tip!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(AppTranslations.get(lang, 'travel_tips'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
              const SizedBox(height: 6),
              Text(tip!, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
