import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../providers/app_state.dart';
import '../services/trip_log_service.dart';
import '../data/spots_db.dart';
import '../utils/translations.dart';

// 여행 보고서(일지/회고) 화면. 앱이 켜져 있는 동안 기록해둔 GPS 궤적과
// 포켓스탑 방문 기록을 하루 단위 또는 전체 여행 통합으로 지도에 다시 그려준다.
class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  List<String> _days = [];
  String? _selectedDay;
  bool _showAllTime = false;
  bool _loading = true;
  List<TripBreadcrumb> _breadcrumbs = [];
  List<TripVisit> _visits = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final days = await TripLogService.listDaysWithData();
    if (!mounted) return;
    setState(() {
      _days = days;
      _selectedDay = days.isNotEmpty ? days.first : null;
    });
    await _loadSelection();
  }

  Future<void> _loadSelection() async {
    setState(() => _loading = true);
    List<TripBreadcrumb> bc = [];
    List<TripVisit> vs = [];
    if (_showAllTime) {
      bc = await TripLogService.getAllBreadcrumbs();
      vs = await TripLogService.getAllVisits();
    } else if (_selectedDay != null) {
      bc = await TripLogService.getBreadcrumbs(_selectedDay!);
      vs = await TripLogService.getVisits(_selectedDay!);
    }
    if (!mounted) return;
    setState(() {
      _breadcrumbs = bc;
      _visits = vs;
      _loading = false;
    });
  }

  void _selectDay(String day) {
    setState(() {
      _showAllTime = false;
      _selectedDay = day;
    });
    _loadSelection();
  }

  void _selectAllTime() {
    setState(() => _showAllTime = true);
    _loadSelection();
  }

  String _cleanTitle(String rawTitle) {
    return rawTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
        .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'trip_report')),
        backgroundColor: const Color(0xFFFDFBF7),
        foregroundColor: const Color(0xFF3E2723),
        elevation: 1,
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (_days.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      AppTranslations.get(lang, 'trip_report_empty'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8D6E63), fontSize: 14),
                    ),
                  ),
                ),
              )
            else ...[
              _buildDaySelector(lang),
              const SizedBox(height: 10),
              _buildStats(lang),
              const SizedBox(height: 10),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                    : _buildMap(lang),
              ),
              if (_visits.isNotEmpty) _buildVisitList(lang),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDaySelector(String lang) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ChoiceChip(
            label: Text(AppTranslations.get(lang, 'trip_report_all_time')),
            selected: _showAllTime,
            onSelected: (_) => _selectAllTime(),
            selectedColor: const Color(0xFFD4AF37),
            labelStyle: TextStyle(
              color: _showAllTime ? Colors.white : const Color(0xFF8D6E63),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          ..._days.map((day) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(day),
                  selected: !_showAllTime && _selectedDay == day,
                  onSelected: (_) => _selectDay(day),
                  selectedColor: const Color(0xFFD4AF37),
                  labelStyle: TextStyle(
                    color: (!_showAllTime && _selectedDay == day) ? Colors.white : const Color(0xFF8D6E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStats(String lang) {
    final distanceKm = TripLogService.totalDistanceMeters(_breadcrumbs) / 1000.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _statCard(Icons.directions_walk, '${distanceKm.toStringAsFixed(1)} km', AppTranslations.get(lang, 'trip_report_distance'))),
          const SizedBox(width: 10),
          Expanded(child: _statCard(Icons.flag, '${_visits.length}', AppTranslations.get(lang, 'trip_report_spots'))),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7CCC8), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63))),
        ],
      ),
    );
  }

  Widget _buildMap(String lang) {
    final points = _breadcrumbs.map((b) => LatLng(b.lat, b.lng)).toList();
    final center = points.isNotEmpty
        ? points[points.length ~/ 2]
        : (_visits.isNotEmpty ? LatLng(_visits.first.lat, _visits.first.lng) : LatLng(35.8348, 129.2266));

    final markers = _visits
        .map((v) => Marker(markerId: '${v.spotTitle}_${v.timestamp.millisecondsSinceEpoch}', latLng: LatLng(v.lat, v.lng)))
        .toList();

    final overlays = _visits.asMap().entries.map((entry) {
      final index = entry.key;
      final visit = entry.value;
      final spotDetail = SpotsDB.get(_cleanTitle(visit.spotTitle));
      final displayName = spotDetail != null ? spotDetail.getName(lang) : visit.spotTitle;
      final timeLabel = '${visit.timestamp.hour.toString().padLeft(2, '0')}:${visit.timestamp.minute.toString().padLeft(2, '0')}';
      return CustomOverlay(
        customOverlayId: 'visit_${index}_${visit.timestamp.millisecondsSinceEpoch}',
        latLng: LatLng(visit.lat, visit.lng),
        content: '''
          <div style="
            background-color: #FFF9E6; padding: 3px 7px; border-radius: 10px;
            border: 2px solid #D4AF37; font-size: 10.5px; font-weight: bold;
            color: #3E2723; white-space: nowrap; box-shadow: 0px 2px 5px rgba(0,0,0,0.2);
            font-family: sans-serif; text-align: center;
          ">
            ${index + 1}. $displayName ($timeLabel)
          </div>
        ''',
        yAnchor: 2.2,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: KakaoMap(
          center: center,
          markers: markers,
          customOverlays: overlays,
          polylines: points.length > 1
              ? [
                  Polyline(
                    polylineId: 'trip_trail',
                    points: points,
                    strokeColor: const Color(0xFFFFC400),
                    strokeWidth: 5,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildVisitList(String lang) {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7CCC8), width: 1.2),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _visits.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final visit = _visits[index];
          final spotDetail = SpotsDB.get(_cleanTitle(visit.spotTitle));
          final displayName = spotDetail != null ? spotDetail.getName(lang) : visit.spotTitle;
          final timeLabel = '${visit.timestamp.hour.toString().padLeft(2, '0')}:${visit.timestamp.minute.toString().padLeft(2, '0')}';
          return SizedBox(
            width: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFD4AF37),
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                  textAlign: TextAlign.center,
                ),
                Text(timeLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF8D6E63))),
              ],
            ),
          );
        },
      ),
    );
  }
}
