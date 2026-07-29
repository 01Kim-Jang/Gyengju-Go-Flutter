import '../lib/data/preloaded_spots.dart';

void main() {
  for (var lang in ['en', 'zh-chs']) {
    print('--- LANGUAGE: $lang ---');
    final list = PreloadedSpots.data[lang] as List;
    for (int i = 0; i < list.length; i++) {
      print('Index $i: "${list[i]['title']}"');
    }
  }
}
