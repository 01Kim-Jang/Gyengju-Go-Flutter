import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/mock_geolocator.dart' hide Position;
import '../services/odii_service.dart';
import '../components/docent_sheet.dart';
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
        builder: (context) => DocentSheet(spotData: spot),
      );
    }
  }
}

class _MapboxViewState extends State<MapboxView> {
  MapboxMap? mapboxMap;
  ViewAnnotationManager? viewAnnotationManager;
  final Map<String, dynamic> _spotsMap = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }
  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    await mapboxMap.style.setStyleURI(MapboxStyles.STANDARD);
    
    try {
      final appState = context.read<AppState>();
      await mapboxMap.style.localizeLabels(appState.currentLanguage, null);
      
      // 사용자 요청: 짜장면, 버스정류장 등 불필요한 POI 제거 (건물은 유지)
      await mapboxMap.style.setStyleImportConfigProperty('basemap', 'showPointOfInterestLabels', false);
      await mapboxMap.style.setStyleImportConfigProperty('basemap', 'showTransitLabels', false);
      await mapboxMap.style.setStyleImportConfigProperty('basemap', 'showPlaceLabels', false);
      await mapboxMap.style.setStyleImportConfigProperty('basemap', 'showRoadLabels', true);
    } catch (e) {
      print("Style update error: $e");
    }
    
    // Terrain is managed via Mapbox Studio style instead of programmatic adding
    
    // Enable user location component
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true, // Pulse effect
        pulsingColor: Colors.blue.value,
        pulsingMaxRadius: 50.0,
      )
    );

    // 뷰 어노테이션(Flutter 위젯 마커) 매니저 생성
    viewAnnotationManager = await mapboxMap.annotations.createViewAnnotationManager();
    
    // 데이터 불러오기 및 마커 렌더링
    _loadSpotsAndRender();
  }

  Future<void> _loadSpotsAndRender() async {
    if (viewAnnotationManager == null) return;
    if (!mounted) return;
    
    final appState = context.read<AppState>();
    final spots = await OdiiService.fetchGyeongjuSpots(appState.currentLanguage);
    
    for (var spot in spots) {
      double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
      double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;
      
      // 제목에서 "(나레이션 ...)" 제거 및 "경주, " 제거
      String rawTitle = spot['title'] ?? 'Unknown';
      String title = rawTitle.replaceAll(RegExp(r'\([^)]*\)'), '').replaceAll('경주, ', '').trim();
      
      _spotsMap[title] = spot;

      String? imageUrl = spot['firstimage'];

      // Flutter 네이티브 위젯으로 뷰 어노테이션 추가
      final markerWidget = GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DocentSheet(spotData: spot),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                color: const Color(0xFF29B6F6),
                image: imageUrl != null && imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      final options = ViewAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        allowOverlap: true,
        anchor: ViewAnnotationAnchor.BOTTOM,
      );

      try {
        await viewAnnotationManager?.addViewAnnotation(
          "marker_$title",
          options,
          markerWidget,
        );
      } catch (e) {
        print("ViewAnnotation error: $e");
      }
    }

    // 3D Hanok Model 일괄 적용 (모든 스팟 좌표에)
    try {
      if (mapboxMap != null) {
        await mapboxMap!.style.addStyleModel('hanok-model', 'asset://assets/scene.gltf');
        
        List<String> features = [];
        for (var spot in spots) {
          double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
          double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;
          features.add('{"type": "Feature", "geometry": {"type": "Point", "coordinates": [$lng, $lat]}}');
        }
        
        String geoJsonData = '{"type": "FeatureCollection", "features": [${features.join(",")}]}';
        
        await mapboxMap!.style.addSource(GeoJsonSource(
          id: 'hanok-points-source',
          data: geoJsonData
        ));

        await mapboxMap!.style.addLayer(ModelLayer(
          id: 'hanok-layer',
          sourceId: 'hanok-points-source',
          modelId: 'hanok-model',
          modelScale: [30.0, 30.0, 30.0], // 한옥 모델 스케일 대폭 증가 (건물 덮어쓰기 위해)
        ));
      }
    } catch (e) {
      print("Hanok Model load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    MapboxOptions.setAccessToken(token);

    Widget mapWidget = MapWidget(
      key: const ValueKey("mapboxWidget"),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(129.2266, 35.8348)),
        zoom: 17.5, // Pokemon Go style zoom
        pitch: 75.0, // Pokemon Go style pitch
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
        R + sat, G, B, 0, 0,
        R, G + sat, B, 0, 0,
        R, G, B + sat, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: mapWidget,
    );
    
    // 2. Contrast (1.1)
    mapWidget = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1.1, 0, 0, 0, -12.75,
        0, 1.1, 0, 0, -12.75,
        0, 0, 1.1, 0, -12.75,
        0, 0, 0, 1, 0,
      ]),
      child: mapWidget,
    );
    
    // 3. 몽환적인 노란/연두빛 감성 (Hue Rotate 대체)
    mapWidget = ColorFiltered(
      colorFilter: ColorFilter.mode(
        const Color(0xFFD4E157).withOpacity(0.15),
        BlendMode.colorBurn,
      ),
      child: mapWidget,
    );

    return mapWidget;
  }
}
