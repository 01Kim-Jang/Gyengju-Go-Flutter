import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../services/odii_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/marker_generator.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../widgets/pokestop_modal.dart';

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
    if (!mounted) return;
    final appState = context.read<AppState>();
    final loadedSpots = await OdiiService.fetchGyeongjuSpots(
      appState.currentLanguage,
    );

    Set<Marker> newMarkers = {};
    for (var spot in loadedSpots) {
      newMarkers.add(
        Marker(
          markerId: spot['title'] ?? 'marker',
          latLng: LatLng(
            double.tryParse(spot['mapY'].toString()) ?? 35.8348,
            double.tryParse(spot['mapX'].toString()) ?? 129.2266,
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        spots = loadedSpots;
        markers = newMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      onMapCreated: ((controller) {
        mapController = controller;
      }),
      markers: markers.toList(),
      center: LatLng(35.8348, 129.2266),
      onMarkerTap: (markerId, latLng, zoomLevel) {
        final spot = spots.firstWhere(
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
  }
}
