import 'dart:typed_data';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  PointAnnotationOptions opts = PointAnnotationOptions(
    geometry: Point(coordinates: Position(0.0, 0.0)),
    image: Uint8List(0),
    iconImage: 'string',
  );
  print(opts);
}
