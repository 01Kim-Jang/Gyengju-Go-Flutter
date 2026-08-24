import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/pokestop_modal.dart';
import '../data/spots_db.dart';
import '../utils/translations.dart';
import '../utils/transit_helper.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}


class _KakaoMapViewState extends State<KakaoMapView> {
  late KakaoMapController mapController;
  geo.Position? _currentPosition;
  StreamSubscription<geo.Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) => _startLocationStream());
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
  }

  void _startLocationStream() {
    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((geo.Position position) {
      if (!mounted) return;
      setState(() => _currentPosition = position);
      context.read<AppState>().updateUserLocation(position.latitude, position.longitude);
    });
  }

  void _moveToMyLocation() {
    if (_currentPosition == null) return;
    mapController.panTo(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    mapController.setLevel(3);
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

    // 내 위치를 표시하는 펄스 도트 오버레이 (네이티브 지도 앱들의 파란 점과 유사한 방식)
    if (_currentPosition != null) {
      mapOverlays.add(
        CustomOverlay(
          customOverlayId: 'my_location',
          latLng: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          content: '''
            <div style="position: relative; width: 22px; height: 22px;">
              <div style="
                position: absolute; top: -9px; left: -9px;
                width: 40px; height: 40px; border-radius: 50%;
                background: rgba(66, 133, 244, 0.25);
              "></div>
              <div style="
                position: absolute; top: 0; left: 0;
                width: 22px; height: 22px; border-radius: 50%;
                background: #4285F4; border: 3px solid white;
                box-shadow: 0px 2px 5px rgba(0,0,0,0.35);
              "></div>
            </div>
          ''',
          yAnchor: 0.5,
        ),
      );
    }

    final List<LatLng> kakaoPolylinePoints = appState.routeCoordinates.map((coords) {
      return LatLng(coords[1], coords[0]);
    }).toList();

    Widget mapWidget = KakaoMap(
      onMapCreated: ((controller) {
        mapController = controller;
        // kakao_map_plugin은 마커/오버레이를 didUpdateWidget에서만 웹뷰로 전송하고
        // 최초 마운트 시에는 보내지 않는다. 지도(WebView JS)가 준비된 이 시점에
        // 한 번 더 build를 트리거해서 이미 갖고 있던 번역된 마커/오버레이가
        // 확실히 반영되도록 한다 (그렇지 않으면 다른 우연한 리빌드가 있기 전까지
        // 명소 이름 라벨이 전혀 나타나지 않는다).
        if (mounted) setState(() {});
      }),
      markers: mapMarkers,
      customOverlays: mapOverlays,
      center: LatLng(35.8348, 129.2266),
      polylines: kakaoPolylinePoints.isNotEmpty
          ? [
              Polyline(
                polylineId: 'route_line',
                points: kakaoPolylinePoints,
                strokeColor: appState.navigationMode == 'walk' ? const Color(0xFFFFC400) : Colors.blue.shade600,
                strokeWidth: 5,
              ),
            ]
          : [],
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
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            );
                          }
                        ),
                      ),
                      if (appState.isFetchingRoute)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeButton(
                        context: context,
                        icon: Icons.directions_walk,
                        label: AppTranslations.get(currentLang, 'walk'),
                        isActive: appState.navigationMode == 'walk' && appState.routeCoordinates.isNotEmpty,
                        onTap: () => appState.setNavigationMode('walk'),
                      ),
                      _buildModeButton(
                        context: context,
                        icon: Icons.directions_car,
                        label: AppTranslations.get(currentLang, 'drive'),
                        isActive: appState.navigationMode == 'drive' && appState.routeCoordinates.isNotEmpty,
                        onTap: () => appState.setNavigationMode('drive'),
                      ),
                      _buildModeButton(
                        context: context,
                        icon: Icons.directions_bus,
                        label: AppTranslations.get(currentLang, 'transit'),
                        isActive: false,
                        onTap: () {
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
                          final targetLat = double.tryParse(target['mapY'].toString()) ?? 35.8348;
                          final targetLng = double.tryParse(target['mapX'].toString()) ?? 129.2266;

                          appState.startTransitAlert();
                          openTransitInfoSheet(
                            context,
                            targetDisplayName: targetDisplayName,
                            lat: targetLat,
                            lng: targetLng,
                            currentLang: currentLang,
                          );
                        },
                      ),
                    ],
                  ),
                  // Active Party Co-Op Indicator Floating Badge
                  if (appState.activeParty != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F3864),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.groups, color: Color(0xFFD4AF37), size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              AppTranslations.get(currentLang, 'party_badge_in_quest')
                                  .replaceAll('{name}', '${AppTranslations.get(currentLang, '${appState.activeParty!.courseId}_title')} ${AppTranslations.get(currentLang, 'party_group_suffix')}')
                                  .replaceAll('{code}', appState.activeParty!.inviteCode)
                                  .replaceAll('{count}', appState.activeParty!.members.length.toString()),
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else if (appState.activeParty != null)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F3864),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups, color: Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 8),
                  // 코스 제목+파티 접미사+코드+인원수가 합쳐진 문자열이라 영어/베트남어
                  // 등에서 배지 폭을 넘기 쉬움 - Flexible + ellipsis로 방어.
                  Flexible(
                    child: Text(
                      AppTranslations.get(currentLang, 'party_badge_standalone')
                          .replaceAll('{name}', '${AppTranslations.get(currentLang, '${appState.activeParty!.courseId}_title')} ${AppTranslations.get(currentLang, 'party_group_suffix')}')
                          .replaceAll('{code}', appState.activeParty!.inviteCode)
                          .replaceAll('{count}', appState.activeParty!.members.length.toString()),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // My Location Button
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            heroTag: "myLocationKakao",
            backgroundColor: const Color(0xFFD4AF37),
            child: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _moveToMyLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4AF37) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isActive ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey.shade700, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
