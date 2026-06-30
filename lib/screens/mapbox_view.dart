import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/mock_geolocator.dart' hide Position;
import '../services/odii_service.dart';
import '../components/docent_sheet.dart';

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

    await mapboxMap.style.setStyleURI(MapboxStyles.STANDARD);
    
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
    
    Uint8List? markerImageBytes;
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load('assets/images/pokestop.png');
      markerImageBytes = bytes.buffer.asUint8List();
    } catch (e) {
      print("Failed to load pokestop image: $e");
    }

    final spots = await OdiiService.fetchGyeongjuSpots();
    
    List<PointAnnotationOptions> optionsList = [];
    for (var spot in spots) {
      double lat = double.tryParse(spot['mapY'].toString()) ?? 35.8348;
      double lng = double.tryParse(spot['mapX'].toString()) ?? 129.2266;
      final title = spot['title'] ?? 'Unknown';
      
      _spotsMap[title] = spot;

      optionsList.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        image: markerImageBytes, // Use Uint8List directly
        iconSize: 0.12, // Reduced icon size for better 3D proportions
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
        zoom: 15.5, // Zoomed in slightly more for 3D view
        pitch: 65.0, // Tilted to see 3D buildings and trees
        bearing: -30.0,
      ),
    );
  }
}
