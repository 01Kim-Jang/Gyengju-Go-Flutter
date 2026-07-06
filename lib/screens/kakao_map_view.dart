import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/pokestop_modal.dart';
import '../data/spots_db.dart';

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
    final isNight = appState.isNightMode;

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

      return CustomOverlay(
        customOverlayId: 'overlay_${spot['title']}',
        latLng: LatLng(
          double.tryParse(spot['mapY'].toString()) ?? 35.8348,
          double.tryParse(spot['mapX'].toString()) ?? 129.2266,
        ),
        // A neat, clickable-looking HTML card that overlays the map markers
        content: '''
          <div style="
            background-color: #FDFBF7; 
            padding: 4px 8px; 
            border-radius: 12px; 
            border: 2px solid #D4AF37; 
            font-size: 11px; 
            font-weight: bold; 
            color: #3E2723; 
            white-space: nowrap; 
            box-shadow: 0px 2px 5px rgba(0,0,0,0.2);
            font-family: sans-serif;
            text-align: center;
          ">
            $displayName
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

    // Apply Night filter overlay if it is night mode
    if (isNight) {
      mapWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.3, 0.0, 0.0, 0.0, 0.0,   // Red
          0.0, 0.35, 0.0, 0.0, 0.0,  // Green
          0.0, 0.0, 0.55, 0.0, 0.0,  // Blue (keep blue tint higher)
          0.0, 0.0, 0.0, 1.0, 0.0,   // Alpha
        ]),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            BlendMode.multiply,
          ),
          child: mapWidget,
        ),
      );
    }

    return mapWidget;
  }
}
