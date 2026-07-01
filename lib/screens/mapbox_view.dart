import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/mock_geolocator.dart' hide Position;
import '../services/odii_service.dart';
import '../components/docent_sheet.dart';
import '../utils/marker_generator.dart';

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
  PointAnnotationManager? pointAnnotationManager;
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

    await mapboxMap.style.setStyleURI("mapbox://styles/jhjang0703/cmr09ioq7002e01stcrp2d9cq");
    
    // Add 3D Terrain
    try {
      await mapboxMap.style.addSource(RasterDemSource(id: "mapbox-dem", url: "mapbox://mapbox.mapbox-terrain-dem-v1"));
      await mapboxMap.style.setTerrain(Terrain(sourceId: "mapbox-dem", exaggeration: 1.5));
    } catch (e) {
      print("Terrain error: $e");
    }
    
    // Enable user location component
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true, // Pulse effect
        pulsingColor: Colors.blue.value,
        pulsingMaxRadius: 50.0,
      )
    );

    // 마커 매니저 생성
    pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    pointAnnotationManager?.addOnPointAnnotationClickListener(AnnotationClickListener(context, _spotsMap));
    
    // 데이터 불러오기 및 마커 렌더링
    _loadSpotsAndRender();
  }

  Future<void> _loadSpotsAndRender() async {
    if (pointAnnotationManager == null) return;
    
    final spots = await OdiiService.fetchGyeongjuSpots();
    
    List<PointAnnotationOptions> optionsList = [];
    for (var spot in spots) {
      double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
      double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;
      final title = spot['title'] ?? 'Unknown';
      
      _spotsMap[title] = spot;

      String? imageUrl;
      // 동궁과 월지에만 사진 적용 (사용자 요청)
      if (title.contains('동궁과 월지')) {
        imageUrl = spot['firstimage']; // Odii API 제공 대표 이미지
      }

      // 다이내믹 포켓스탑 마커 생성
      final Uint8List markerImageBytes = await MarkerGenerator.createPokestopMarker(imageUrl: imageUrl);

      optionsList.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        image: markerImageBytes, // Use dynamically generated image
        iconSize: 0.8, // Adjusted size for generated canvas
        iconAnchor: IconAnchor.BOTTOM, // Anchor to the bottom so it sits on the ground
        textField: title, 
        textSize: 14.0,
        textColor: Colors.black.value,
        textHaloColor: Colors.white.value,
        textHaloWidth: 2.0,
        textOffset: [0.0, 1.0], // Adjusted text offset
      ));
    }
    
    await pointAnnotationManager?.createMulti(optionsList);
  }

  @override
  Widget build(BuildContext context) {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    MapboxOptions.setAccessToken(token);

    return MapWidget(
      key: const ValueKey("mapboxWidget"),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(129.2266, 35.8348)),
        zoom: 14.5, // Reverted to Web-like zoom
        pitch: 60.0,
        bearing: -20.0,
      ),
    );
  }
}
