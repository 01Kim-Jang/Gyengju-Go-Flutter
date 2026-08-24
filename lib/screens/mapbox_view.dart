import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../widgets/pokestop_modal.dart';
import '../utils/marker_generator.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend_profile.dart';
import '../data/spots_db.dart';
import '../utils/translations.dart';
import '../utils/transit_helper.dart';

class MapboxView extends StatefulWidget {
  const MapboxView({super.key});

  @override
  State<MapboxView> createState() => _MapboxViewState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  final BuildContext context;
  final Map<String, dynamic> spotsMap;
  final Function(Map<String, dynamic> spot) onSpotClick;

  AnnotationClickListener(this.context, this.spotsMap, this.onSpotClick);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    // Marker id matches spot id or title
    final title = annotation.textField;
    if (title != null && spotsMap.containsKey(title)) {
      final spot = spotsMap[title];
      onSpotClick(spot);
    }
  }
}

class _MapboxViewState extends State<MapboxView> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? playerAnnotation;
  final Map<String, dynamic> _spotsMap = {};
  final Map<String, PointAnnotation> _friendAnnotations = {};
  final Map<String, String> _friendAnnotationCharPath = {};

  List<Map<String, dynamic>> _spotsData = [];
  geo.Position? _currentPosition;
  bool _isRendering = false;
  double _currentZoom = 16.0;
  bool? _lastNightMode;

  AppState? _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newAppState = Provider.of<AppState>(context);
    if (_appState != newAppState) {
      _appState?.removeListener(_onAppStateChanged);
      _appState = newAppState;
      _appState?.addListener(_onAppStateChanged);
      
      // If map is already loaded, draw immediately on state change
      if (mapboxMap != null) {
        _drawRoutePolyline(newAppState.routeCoordinates);
      }
    }
  }

  @override
  void dispose() {
    _appState?.removeListener(_onAppStateChanged);
    _stopCinematicCamera();
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mapboxMap != null && _appState != null) {
      _drawRoutePolyline(_appState!.routeCoordinates);
      _updateFriendAnnotations(_appState!.sharingFriends);
    }
  }

  // 위치 공유를 켜둔 친구들을 캐릭터 마커 + 이름표로 지도에 표시한다.
  // (여성안심/자녀안심 성격의 안전 기능)
  Future<void> _updateFriendAnnotations(List<FriendProfile> friends) async {
    if (pointAnnotationManager == null) return;

    final currentUids = friends.map((f) => f.uid).toSet();

    final toRemove = _friendAnnotations.keys.where((uid) => !currentUids.contains(uid)).toList();
    for (final uid in toRemove) {
      final annotation = _friendAnnotations.remove(uid);
      _friendAnnotationCharPath.remove(uid);
      if (annotation != null) {
        await pointAnnotationManager?.delete(annotation);
      }
    }

    for (final friend in friends) {
      if (friend.lat == null || friend.lng == null) continue;
      final existing = _friendAnnotations[friend.uid];

      if (existing == null || _friendAnnotationCharPath[friend.uid] != friend.characterPath) {
        if (existing != null) {
          await pointAnnotationManager?.delete(existing);
        }
        final imageBytes = await MarkerGenerator.createPlayerMarker(friend.characterPath);
        final created = await pointAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(friend.lng!, friend.lat!)),
            image: imageBytes,
            iconSize: 1.1,
            iconAnchor: IconAnchor.BOTTOM,
            textField: friend.nickname,
            textSize: 13.0,
            textColor: Colors.white.value,
            textHaloColor: const Color(0xFF1F3864).value,
            textHaloWidth: 1.5,
            textOffset: const [0.0, -3.2],
          ),
        );
        if (created != null) {
          _friendAnnotations[friend.uid] = created;
          _friendAnnotationCharPath[friend.uid] = friend.characterPath;
        }
      } else {
        existing.geometry = Point(coordinates: Position(friend.lng!, friend.lat!));
        await pointAnnotationManager?.update(existing);
      }
    }
  }

  Future<void> _drawRoutePolyline(List<List<double>> coordinates) async {
    if (mapboxMap == null) return;
    
    try {
      final isLoaded = await mapboxMap!.style.styleSourceExists('route-source');
      
      if (coordinates.isEmpty) {
        if (isLoaded) {
          await mapboxMap!.style.removeStyleLayer('route-layer');
          await mapboxMap!.style.removeStyleSource('route-source');
        }
        return;
      }

      final routeGeoJson = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "properties": {},
            "geometry": {
              "type": "LineString",
              "coordinates": coordinates,
            }
          }
        ]
      };
      final geoJsonStr = jsonEncode(routeGeoJson);

      if (isLoaded) {
        // Safe recreate to bypass different SDK version signature variations of updateStyleGeoJSONSource
        await mapboxMap!.style.removeStyleLayer('route-layer');
        await mapboxMap!.style.removeStyleSource('route-source');
      }
      
      await mapboxMap!.style.addSource(
        GeoJsonSource(id: 'route-source', data: geoJsonStr),
      );
      
      await mapboxMap!.style.addLayer(
        LineLayer(
          id: 'route-layer',
          sourceId: 'route-source',
          lineColor: Colors.amber.value, // Beautiful glowing golden trail
          lineWidth: 6.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
      );
    } catch (e) {
      debugPrint('Error drawing route on Mapbox: $e');
    }
  }

  List<Point> _generateTreeCoordinates() {
    final List<Point> points = [];
    final random = math.Random(12345); // Seeded random to keep tree positions stable

    void addCluster(double centerLng, double centerLat, double radius, int count) {
      for (int i = 0; i < count; i++) {
        final double r = random.nextDouble() * radius;
        final double theta = random.nextDouble() * 2 * math.pi;
        final double lng = centerLng + r * math.cos(theta);
        final double lat = centerLat + r * math.sin(theta);
        points.add(Point(coordinates: Position(lng, lat)));
      }
    }

    // 1. Gyerim Forest (계림) - dense tree coverage
    addCluster(129.2173376, 35.8322427, 0.0012, 45);

    // 2. Cheomseongdae (첨성대) surroundings - green grass and paths
    addCluster(129.2190631, 35.8346828, 0.0018, 35);

    // 3. Daereungwon (대릉원) park interior - lawns and pathways
    addCluster(129.213332, 35.8382204, 0.0016, 45);

    // 4. Woljeonggyo (월정교) riverside green spaces and walking paths
    addCluster(129.2154713, 35.8291971, 0.0011, 20);

    // 5. Banwolseong (반월성) forest ramparts
    addCluster(129.2228957, 35.8324055, 0.0015, 30);

    return points;
  }

  Future<void> _setupTrees() async {
    if (mapboxMap == null) return;

    try {
      final coordinates = _generateTreeCoordinates();
      final treeGeoJson = {
        "type": "FeatureCollection",
        "features": coordinates.map((pt) => {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "Point",
            "coordinates": [pt.coordinates.lng, pt.coordinates.lat]
          }
        }).toList()
      };
      
      final geoJsonStr = jsonEncode(treeGeoJson);
      final isSourceLoaded = await mapboxMap!.style.styleSourceExists('tree-source');

      if (isSourceLoaded) {
        await mapboxMap!.style.removeStyleLayer('tree-layer');
        await mapboxMap!.style.removeStyleSource('tree-source');
      }

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: 'tree-source', data: geoJsonStr),
      );

      await mapboxMap!.style.addLayer(
        SymbolLayer(
          id: 'tree-layer',
          sourceId: 'tree-source',
          iconImage: 'park-15',
          iconSize: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
        ),
      );
    } catch (e) {
      debugPrint("Error rendering trees: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) {
      _startLocationStream();
    });
    // 위치 공유 설정과 친구 목록 감시를 게임모드 진입 시점에 미리 시작해둔다.
    // (친구/소셜 탭을 아직 한 번도 안 열었어도 안전 기능이 바로 동작하도록)
    context.read<AppState>().loadMyProfile();
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
    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 2, // smaller distance filter for smoother walking
      ),
    ).listen((geo.Position position) {
      if (mounted) {
        _currentPosition = position;
        context.read<AppState>().updateUserLocation(position.latitude, position.longitude);
        _updateMarkersGlow();
        _updatePlayerAnnotation();
      }
    });
  }

  Future<void> _updatePlayerAnnotation() async {
    if (_currentPosition == null || pointAnnotationManager == null || !mounted) return;
    
    double zoomScale = math.pow(2.0, _currentZoom - 16.0).toDouble();
    zoomScale = zoomScale.clamp(0.5, 4.0);
    double playerSize = 1.2 * zoomScale;

    if (playerAnnotation == null) {
      final String charPath = context.read<AppState>().selectedCharacterPath;
      final Uint8List imageBytes = await MarkerGenerator.createPlayerMarker(charPath);
      playerAnnotation = await pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(_currentPosition!.longitude, _currentPosition!.latitude)),
          image: imageBytes,
          iconSize: playerSize, // dynamically scaled based on zoom
          iconAnchor: IconAnchor.BOTTOM,
        )
      );
    } else {
      playerAnnotation!.geometry = Point(coordinates: Position(_currentPosition!.longitude, _currentPosition!.latitude));
      playerAnnotation!.iconSize = playerSize;
      await pointAnnotationManager?.update(playerAnnotation!);
    }
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    final isNight = context.read<AppState>().isNightMode;
    _lastNightMode = isNight;

    // initState 시점엔 Firebase 초기화가 아직 안 끝났을 수 있어(백그라운드 초기화),
    // 지도가 완전히 뜬 이 시점에 한 번 더 시도해 친구 위치 공유 감시가 확실히 시작되도록 한다.
    context.read<AppState>().loadMyProfile();

    // Mapbox 기본 나침반/축척 표시가 화면 맨 위(0,0) 기준으로 그려져서 상태바(시간·와이파이·배터리)와
    // 겹쳐 보이던 문제 수정. 상태바 높이만큼 아래로 여백을 줘서 겹치지 않게 한다.
    try {
      final statusBarHeight = MediaQuery.of(context).padding.top;
      await mapboxMap.compass.updateSettings(CompassSettings(marginTop: statusBarHeight + 8));
      await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(marginTop: statusBarHeight + 8));

      // Mapbox 로고/저작권 표시는 라이선스상 완전히 숨길 수 없다(logo.enabled는
      // Mapbox와 별도 협의가 필요한 "Restricted API"). 대신 좌하단 AI 비서
      // 버튼과 겹치지 않도록 우하단으로 옮겨서 항상 온전히 보이게 한다.
      await mapboxMap.logo.updateSettings(LogoSettings(position: OrnamentPosition.BOTTOM_RIGHT));
      await mapboxMap.attribution.updateSettings(AttributionSettings(position: OrnamentPosition.BOTTOM_RIGHT));
    } catch (e) {
      debugPrint("Ornament margin update error: $e");
    }

    await mapboxMap.style.setStyleURI(isNight ? MapboxStyles.DARK : MapboxStyles.STANDARD);

    try {
      final appState = context.read<AppState>();

      // Mapbox Standard 스타일의 언어 설정은 basemap config로 제어
      await mapboxMap.style.setStyleImportConfigProperty(
        'basemap',
        'language',
        appState.currentLanguage,
      );

      // 사용자 요청: 짜장면 등 불필요한 POI 제거, 단 버스정류장(transit)은 복구
      await mapboxMap.style.setStyleImportConfigProperty(
        'basemap',
        'showPointOfInterestLabels',
        false,
      );
      await mapboxMap.style.setStyleImportConfigProperty(
        'basemap',
        'showTransitLabels',
        true,
      );
      await mapboxMap.style.setStyleImportConfigProperty(
        'basemap',
        'showPlaceLabels',
        false,
      );
      await mapboxMap.style.setStyleImportConfigProperty(
        'basemap',
        'showRoadLabels',
        true,
      );
    } catch (e) {
      debugPrint("Style update error: $e");
    }

    // Terrain is managed via Mapbox Studio style instead of programmatic adding

    // Enable user location component with default puck (blue dot)
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true, // Pulse effect
        pulsingColor: Colors.blue.value,
        pulsingMaxRadius: 50.0,
      ),
    );

    // 마커 매니저 생성
    pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    await pointAnnotationManager?.setIconAllowOverlap(true);
    await pointAnnotationManager?.setTextAllowOverlap(true);
    pointAnnotationManager?.addOnPointAnnotationClickListener(
      AnnotationClickListener(context, _spotsMap, (spot) {
        _startCinematicCamera(spot);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PokestopModal(spotData: spot),
        ).then((_) {
          _stopCinematicCamera();
        });
      }),
    );

    // 데이터 불러오기 및 마커 렌더링
    _loadSpotsAndRender();
    _updateFriendAnnotations(context.read<AppState>().sharingFriends);

    // Plant trees in Gyeongju green areas
    _setupTrees();

    // Draw route if already exists in AppState
    if (context.read<AppState>().routeCoordinates.isNotEmpty) {
      _drawRoutePolyline(context.read<AppState>().routeCoordinates);
    }
  }

  Future<void> _loadSpotsAndRender() async {
    if (pointAnnotationManager == null) return;
    if (!mounted) return;

    final appState = context.read<AppState>();
    final spots = appState.spotsData;
    _spotsData = spots;
    await _renderMarkers();

    // 3D Hanok Model 일괄 적용 (모든 스팟 좌표에)
    try {
      if (mapboxMap != null) {
        await mapboxMap!.style.addStyleModel(
          'hanok-model',
          'asset://assets/scene.gltf',
        );

        List<String> features = [];
        for (var spot in spots) {
          double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
          double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;
          features.add(
            '{"type": "Feature", "geometry": {"type": "Point", "coordinates": [$lng, $lat]}}',
          );
        }

        String geoJsonData =
            '{"type": "FeatureCollection", "features": [${features.join(",")}]}';

        await mapboxMap!.style.addSource(
          GeoJsonSource(id: 'hanok-points-source', data: geoJsonData),
        );

        await mapboxMap!.style.addLayer(
          ModelLayer(
            id: 'hanok-layer',
            sourceId: 'hanok-points-source',
            modelId: 'hanok-model',
            modelScale: [30.0, 30.0, 30.0], // 한옥 모델 스케일 대폭 증가 (건물 덮어쓰기 위해)
          ),
        );
      }
    } catch (e) {
      debugPrint("Hanok Model load error: $e");
    }
  }

  Future<void> _renderMarkers() async {
    if (pointAnnotationManager == null || _isRendering || !mounted) return;
    _isRendering = true;

    try {
      final appState = context.read<AppState>();
      final activeQuest = appState.quests.where((q) => q.isActive).firstOrNull;
      final targetTitle = activeQuest?.currentTargetSpot?['title']?.toString() ?? '';

      await pointAnnotationManager?.deleteAll();
      playerAnnotation = null;

      List<PointAnnotationOptions> optionsList = [];

      for (var spot in _spotsData) {
        double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
        double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;

        String rawTitle = spot['title'] ?? 'Unknown';
        String title = rawTitle
            .replaceAll(RegExp(r'\([^)]*\)'), '')
            .replaceAll('경주, ', '')
            .trim();
        _spotsMap[title] = spot;
        
        // Use local image if available, fallback to remote firstimage
        final String? localPath = MarkerGenerator.getLocalImagePath(
          spot['title'] ?? '',
          mapX: spot['mapX']?.toString(),
          mapY: spot['mapY']?.toString(),
        );
        String? imageUrl = localPath ?? spot['firstimage'];

        bool isTarget = (spot['title'] == targetTitle);
        bool isGlowing = isTarget;
        
        if (_currentPosition != null) {
          double distance = geo.Geolocator.distanceBetween(
            _currentPosition!.latitude, 
            _currentPosition!.longitude, 
            lat, 
            lng
          );
          if (distance < 50) isGlowing = true;
        }

        final Uint8List markerImageBytes = await MarkerGenerator.createPokestopMarker(
          title: title, imageUrl: imageUrl, isGlowing: isGlowing);
        
        // Calculate dynamic scale based on zoom (base zoom 16.0)
        double zoomScale = math.pow(2.0, _currentZoom - 16.0).toDouble();
        zoomScale = zoomScale.clamp(0.5, 4.0);
        double baseSize = isTarget ? 1.5 : (isGlowing ? 1.0 : 0.8);
        
        optionsList.add(PointAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          image: markerImageBytes,
          iconSize: baseSize * zoomScale,
          iconAnchor: IconAnchor.BOTTOM,
            textField: title,
            textSize: isTarget ? 16.0 : 14.0,
            textColor: isTarget ? Colors.red.value : Colors.black.value,
            textHaloColor: Colors.white.value,
            textHaloWidth: 2.0,
            textOffset: [0.0, 1.0],
          ),
        );
      }

      await pointAnnotationManager?.createMulti(optionsList);
      _updatePlayerAnnotation();
    } finally {
      _isRendering = false;
    }
  }

  void _updateMarkersGlow() {
    _renderMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    MapboxOptions.setAccessToken(token);
    
    // Listen to AppState changes (like quest target updates) to re-render markers
    final appState = context.watch<AppState>();
    final isNight = appState.isNightMode;
    if (mapboxMap != null && _lastNightMode != isNight) {
      _lastNightMode = isNight;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await mapboxMap!.style.setStyleURI(isNight ? MapboxStyles.DARK : MapboxStyles.STANDARD);
        // Wait for style layout transition, then re-populate custom layers
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && mapboxMap != null) {
            _setupTrees();
            _drawRoutePolyline(appState.routeCoordinates);
          }
        });
      });
    }

    Widget mapWidget = MapWidget(
      key: const ValueKey("mapboxWidget"),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(129.2266, 35.8348)),
        zoom: 16.0,
        pitch: 75.0, // 극단적인 포켓몬고 스타일 항공샷
        bearing: -20.0,
      ),
    );

    // CSS 필터 복원: saturate(130%) contrast(110%) hue-rotate(10deg) + 따뜻한 색감

    // 1. Saturate (1.3)
    const double sat = 1.3;
    const double invSat = 1 - sat;
    const double R = 0.2126 * invSat;
    const double G = 0.7152 * invSat;
    const double B = 0.0722 * invSat;
    mapWidget = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        R + sat,
        G,
        B,
        0,
        0,
        R,
        G + sat,
        B,
        0,
        0,
        R,
        G,
        B + sat,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: mapWidget,
    );

    // 2. Contrast (1.1)
    mapWidget = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1.1,
        0,
        0,
        0,
        -12.75,
        0,
        1.1,
        0,
        0,
        -12.75,
        0,
        0,
        1.1,
        0,
        -12.75,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: mapWidget,
    );

    // 3. 몽환적인 밤/어두운 감성 (Hue Rotate 등)
    mapWidget = ColorFiltered(
      colorFilter: ColorFilter.mode(
        const Color(0xFFD4E157).withOpacity(0.15),
        BlendMode.colorBurn,
      ),
      child: mapWidget,
    );

    return Stack(
      children: [
        mapWidget,
        Positioned(
          left: 16,
          bottom: 100, // Above the bottom navigation bar
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Gold border
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${appState.score} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Show active quest target floating banner at the top of the map
        Consumer<AppState>(
          builder: (context, appState, child) {
            final activeQuest = appState.quests.where((q) => q.isActive).firstOrNull;
            if (activeQuest?.currentTargetSpot != null) {
              final target = activeQuest!.currentTargetSpot!;
              return Positioned(
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
                                final rawTarget = target['title'] ?? '';
                                final cleanTarget = rawTarget
                                    .replaceAll(RegExp(r'\([^)]*\)'), '')
                                    .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                                    .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
                                    .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
                                    .trim();
                                final targetDetail = SpotsDB.get(cleanTarget);
                                final targetDisplayName = targetDetail != null 
                                    ? targetDetail.getName(appState.currentLanguage) 
                                    : rawTarget;
                                final targetLabel = AppTranslations.get(appState.currentLanguage, 'planner_current_target');
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
                            label: AppTranslations.get(appState.currentLanguage, 'walk'),
                            isActive: appState.navigationMode == 'walk' && appState.routeCoordinates.isNotEmpty,
                            onTap: () => appState.setNavigationMode('walk'),
                          ),
                          _buildModeButton(
                            context: context,
                            icon: Icons.directions_car,
                            label: AppTranslations.get(appState.currentLanguage, 'drive'),
                            isActive: appState.navigationMode == 'drive' && appState.routeCoordinates.isNotEmpty,
                            onTap: () => appState.setNavigationMode('drive'),
                          ),
                          _buildModeButton(
                            context: context,
                            icon: Icons.directions_bus,
                            label: AppTranslations.get(appState.currentLanguage, 'transit'),
                            isActive: false,
                            onTap: () {
                              final rawTarget = target['title'] ?? '';
                              final cleanTarget = rawTarget
                                  .replaceAll(RegExp(r'\([^)]*\)'), '')
                                  .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                                  .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
                                  .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
                                  .trim();
                              final targetDetail = SpotsDB.get(cleanTarget);
                              final targetDisplayName = targetDetail != null
                                  ? targetDetail.getName(appState.currentLanguage)
                                  : rawTarget;
                              final targetLat = double.tryParse(target['mapY'].toString()) ?? 35.8348;
                              final targetLng = double.tryParse(target['mapX'].toString()) ?? 129.2266;

                              appState.startTransitAlert();
                              openTransitInfoSheet(
                                context,
                                targetDisplayName: targetDisplayName,
                                lat: targetLat,
                                lng: targetLng,
                                currentLang: appState.currentLanguage,
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
                                  AppTranslations.get(appState.currentLanguage, 'party_badge_in_quest')
                                      .replaceAll('{name}', '${AppTranslations.get(appState.currentLanguage, '${appState.activeParty!.courseId}_title')} ${AppTranslations.get(appState.currentLanguage, 'party_group_suffix')}')
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
              );
            } else if (appState.activeParty != null) {
              // Show Party Badge alone if no quest active
              return Positioned(
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
                          AppTranslations.get(appState.currentLanguage, 'party_badge_standalone')
                              .replaceAll('{name}', '${AppTranslations.get(appState.currentLanguage, '${appState.activeParty!.courseId}_title')} ${AppTranslations.get(appState.currentLanguage, 'party_group_suffix')}')
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // My Location Button
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            heroTag: "myLocationMapbox",
            backgroundColor: const Color(0xFFD4AF37),
            child: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              if (_currentPosition != null && mapboxMap != null) {
                mapboxMap!.flyTo(
                  CameraOptions(
                    center: Point(
                      coordinates: Position(_currentPosition!.longitude, _currentPosition!.latitude),
                    ),
                    zoom: 16.0,
                  ),
                  MapAnimationOptions(duration: 1000),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Timer? _cinematicTimer;

  void _startCinematicCamera(Map<String, dynamic> spot) {
    if (mapboxMap == null) return;
    _stopCinematicCamera();

    final double lat = double.tryParse(spot['mapY']?.toString() ?? '') ?? 35.8348;
    final double lng = double.tryParse(spot['mapX']?.toString() ?? '') ?? 129.2266;

    // Fly to focus the spot without spinning/rotating (prevents dizziness)
    mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 17.5,
        pitch: 65.0,
        bearing: 0.0,
      ),
      MapAnimationOptions(duration: 1500),
    );
  }

  void _stopCinematicCamera() {
    _cinematicTimer?.cancel();
    _cinematicTimer = null;
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
