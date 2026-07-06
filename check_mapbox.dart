import 'dart:typed_data';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  PointAnnotationOptions opts = PointAnnotationOptions(
    image: Uint8List(0), // Corrected to Uint8List
    iconImage: 'string',
  );
}
