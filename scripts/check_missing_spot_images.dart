import 'dart:io';
import '../lib/data/preloaded_spots.dart';
import '../lib/utils/marker_generator.dart';

void main() {
  final spots = PreloadedSpots.data['ko'] as List;
  print('Total spots in DB: ${spots.length}');

  int missingLocal = 0;
  for (var spot in spots) {
    final title = spot['title'] ?? '';
    final localPath = MarkerGenerator.getLocalImagePath(title);
    if (localPath == null) {
      missingLocal++;
      print('Spot: "$title", Remote URL: "${spot['firstimage']}"');
    }
  }
  print('Total spots missing local image mapping: $missingLocal');
}
