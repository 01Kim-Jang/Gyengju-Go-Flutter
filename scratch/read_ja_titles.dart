import '../lib/data/preloaded_spots.dart';

void main() {
  final list = PreloadedSpots.data['ja'] as List;
  for (int i = 0; i < list.length; i++) {
    print('Index $i: "${list[i]['title']}" (${list[i]['mapX']}, ${list[i]['mapY']})');
  }
}
