import '../lib/data/preloaded_spots.dart';

void main() {
  for (var lang in ['ko', 'en', 'ja', 'zh-chs']) {
    print('=== $lang ===');
    final list = PreloadedSpots.data[lang] as List;
    for (int i = 0; i < list.length; i++) {
      final title = list[i]['title'] ?? '';
      if (title.contains('대릉원') || title.contains('大陵') || title.contains('Daereung') || title.contains('テヌン')) {
        print('Index $i: "$title"');
      }
    }
  }
}
