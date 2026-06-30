import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../services/odii_service.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView> {
  late KakaoMapController mapController;
  Set<Marker> markers = {};
  List<Map<String, dynamic>> spots = [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    final loadedSpots = await OdiiService.fetchGyeongjuSpots();
    setState(() {
      spots = loadedSpots;
      markers = spots.map((spot) {
        return Marker(
          markerId: spot['title'] ?? 'marker',
          latLng: LatLng(
            double.tryParse(spot['mapY'].toString()) ?? 35.8348,
            double.tryParse(spot['mapX'].toString()) ?? 129.2266,
          ),
          infoWindowContent: spot['title'],
          // Default KakaoMap marker will be used since markerImageSrc is removed
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      onMapCreated: ((controller) {
        mapController = controller;
      }),
      markers: markers.toList(),
      center: LatLng(35.8348, 129.2266),
    );
  }
}
