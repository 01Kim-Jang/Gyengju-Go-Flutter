import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../widgets/pokestop_modal.dart';
import '../data/spots_db.dart';
import '../utils/translations.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}


class _KakaoMapViewState extends State<KakaoMapView> {
  late KakaoMapController mapController;

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
    final appState = context.watch<AppState>();
    final currentLang = appState.currentLanguage;
    final loadedSpots = appState.spotsData;
    final activeQuest = appState.quests.where((q) => q.isActive).firstOrNull;
    final currentTargetSpot = activeQuest?.currentTargetSpot;
    final targetTitle = currentTargetSpot?['title']?.toString() ?? '';

    // Create markers reactively
    final List<Marker> mapMarkers = loadedSpots.map((spot) {
      return Marker(
        markerId: spot['title'] ?? 'marker',
        latLng: LatLng(
          double.tryParse(spot['mapY'].toString()) ?? 35.8348,
          double.tryParse(spot['mapX'].toString()) ?? 129.2266,
        ),
      );
    }).toList();

    // Create custom overlays reactively to show translated names above markers
    final List<CustomOverlay> mapOverlays = loadedSpots.map((spot) {
      final rawTitle = spot['title'] ?? 'Marker';
      final clean = _cleanTitle(rawTitle);
      final spotDetail = SpotsDB.get(clean);
      final displayName = spotDetail != null ? spotDetail.getName(currentLang) : rawTitle;

      final bool isTarget = (spot['title'] == targetTitle);
      final borderStyle = isTarget ? '3px solid #E53935' : '2px solid #D4AF37';
      final bgStyle = isTarget ? '#FFF9C4' : '#FDFBF7';
      final prefix = isTarget ? '🎯 ' : '';
      final fontSizeStyle = isTarget ? '13px' : '11px';

      return CustomOverlay(
        customOverlayId: 'overlay_${spot['title']}',
        latLng: LatLng(
          double.tryParse(spot['mapY'].toString()) ?? 35.8348,
          double.tryParse(spot['mapX'].toString()) ?? 129.2266,
        ),
        // A neat, clickable-looking HTML card that overlays the map markers
        content: '''
          <div style="
            background-color: $bgStyle; 
            padding: 4px 8px; 
            border-radius: 12px; 
            border: $borderStyle; 
            font-size: $fontSizeStyle; 
            font-weight: bold; 
            color: #3E2723; 
            white-space: nowrap; 
            box-shadow: 0px 2px 5px rgba(0,0,0,0.2);
            font-family: sans-serif;
            text-align: center;
          ">
            $prefix$displayName
          </div>
        ''',
        yAnchor: 2.2, // Offset above the marker pin
      );
    }).toList();

    Widget mapWidget = KakaoMap(
      onMapCreated: ((controller) {
        mapController = controller;
      }),
      markers: mapMarkers,
      customOverlays: mapOverlays,
      center: LatLng(35.8348, 129.2266),
      onMarkerTap: (markerId, latLng, zoomLevel) {
        final spot = loadedSpots.firstWhere(
          (s) => s['title'] == markerId,
          orElse: () => {},
        );
        if (spot.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PokestopModal(spotData: spot),
          );
        }
      },
    );

    return Stack(
      children: [
        mapWidget,
        // Show active quest target floating banner at the top of the Kakao Map
        if (currentTargetSpot != null)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final target = currentTargetSpot;
                final rawTarget = target['title'] ?? '';
                final cleanTarget = rawTarget
                    .replaceAll(RegExp(r'\([^)]*\)'), '')
                    .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                    .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
                    .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
                    .trim();
                
                final lat = target['mapY']?.toString() ?? '';
                final lng = target['mapX']?.toString() ?? '';
                
                final urlString = 'https://map.kakao.com/link/to/$cleanTarget,$lat,$lng';
                final uri = Uri.parse(urlString);
                
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.get(currentLang, 'cannot_launch_directions'),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final target = currentTargetSpot;
                          final rawTarget = target['title'] ?? '';
                          final cleanTarget = rawTarget
                              .replaceAll(RegExp(r'\([^)]*\)'), '')
                              .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                              .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
                              .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
                              .trim();
                          final targetDetail = SpotsDB.get(cleanTarget);
                          final targetDisplayName = targetDetail != null 
                              ? targetDetail.getName(currentLang) 
                              : rawTarget;
                          final targetLabel = AppTranslations.get(currentLang, 'planner_current_target');
                          return Text(
                            "$targetLabel: $targetDisplayName",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          );
                        }
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
