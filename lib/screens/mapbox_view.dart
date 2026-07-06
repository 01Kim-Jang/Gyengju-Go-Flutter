import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../services/odii_service.dart';
import '../widgets/pokestop_modal.dart';
import '../utils/marker_generator.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class MapboxView extends StatefulWidget {
  const MapboxView({super.key});

  @override
  State<MapboxView> createState() => _MapboxViewState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  final BuildContext context;
  final Map<String, dynamic> spotsMap;

  AnnotationClickListener(this.context, this.spotsMap);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    // Marker id matches spot id or title
    final title = annotation.textField;
    if (title != null && spotsMap.containsKey(title)) {
      final spot = spotsMap[title];
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PokestopModal(spotData: spot),
      );
    }
  }
}

class _MapboxViewState extends State<MapboxView> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? playerAnnotation;
  final Map<String, dynamic> _spotsMap = {};

  List<Map<String, dynamic>> _spotsData = [];
  geo.Position? _currentPosition;
  bool _isRendering = false;
  double _currentZoom = 16.0;
  bool? _lastNightMode;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) {
      _startLocationStream();
    });
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
      print("Style update error: $e");
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
      AnnotationClickListener(context, _spotsMap),
    );

    // 데이터 불러오기 및 마커 렌더링
    _loadSpotsAndRender();
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
      print("Hanok Model load error: $e");
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
        String? imageUrl = spot['firstimage'];

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapboxMap!.style.setStyleURI(isNight ? MapboxStyles.DARK : MapboxStyles.STANDARD);
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "목적지: ${target['title']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
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
}
