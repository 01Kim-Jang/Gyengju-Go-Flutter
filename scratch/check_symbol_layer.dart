import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void check() {
  final layer = SymbolLayer(
    id: 'test-layer',
    sourceId: 'test-source',
    iconImage: 'park-15',
    iconSize: 1.5,
    iconAllowOverlap: true,
    iconIgnorePlacement: true,
  );
  print(layer);
}

void main() {}
