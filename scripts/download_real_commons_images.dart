import 'dart:io';
import 'package:http/http.dart' as http;

final Map<String, String> realDownloads = {
  '경주_괘릉.jpg': 'https://upload.wikimedia.org/wikipedia/commons/c/cb/Gyeongju_Gwaereung_Tomb_07.jpg',
  '감은사지.jpg': 'https://upload.wikimedia.org/wikipedia/commons/1/18/Korea-Gyeongju-Gameunsa_temple_pagodas-01.jpg',
  '경주_문무대왕릉.jpg': 'https://upload.wikimedia.org/wikipedia/commons/9/93/Tomb_of_King_Munmu.jpg',
  '경주_무열왕릉.jpg': 'https://upload.wikimedia.org/wikipedia/commons/b/b3/King_Tae-Jong%27s_Tomb_01.jpg',
  '경주_김유신묘.jpg': 'https://upload.wikimedia.org/wikipedia/commons/0/07/Tomb_of_Kim_Yu-sin_02.jpg',
  '경주_알영정.jpg': 'https://upload.wikimedia.org/wikipedia/commons/c/cb/Gyeongju_Poseokjeong_03.jpg',
  '경주_양동마을.jpg': 'https://upload.wikimedia.org/wikipedia/commons/2/22/Yangdong_Folk_Village_01.jpg',
  '경주_경주남산.jpg': 'https://upload.wikimedia.org/wikipedia/commons/8/87/Gyeongju_Namsan_Buddha_Relief.jpg',
  '경주_천년고도_도심_답사길.jpg': 'https://upload.wikimedia.org/wikipedia/commons/6/66/Street_of_Hanok-styled_houses_in_Gyeongju.jpg',
  '교촌마을.jpg': 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Gyeongju_Gyochon_Folk_Village_03.jpg',
  '경주_토함산.jpg': 'https://upload.wikimedia.org/wikipedia/commons/f/f6/Seokguram_interior_3.jpg',
  '경주_보문정.jpg': 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Gyeongju_Bomun_Lake_02.jpg',
  '경주_보문관광단지.jpg': 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Gyeongju_Bomun_Lake_02.jpg',
  '경주_세심마을.jpg': 'https://upload.wikimedia.org/wikipedia/commons/a/a2/Traditional_Korean_village_houses.jpg',
  '경주_도다리.jpg': 'https://upload.wikimedia.org/wikipedia/commons/c/cc/Gyeongju_traditional_market_01.jpg',
  '경주_막걸리.jpg': 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Makgeolli_in_bowl.jpg',
};

Future<void> main() async {
  final dir = Directory('assets/images/spots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Downloading real historical photos from Wikimedia Commons with custom User-Agent...');
  for (var entry in realDownloads.entries) {
    final file = File('${dir.path}/${entry.key}');
    print('Downloading ${entry.key}...');
    try {
      final response = await http.get(
        Uri.parse(entry.value),
        headers: {
          'User-Agent': 'GyeongjuGOFlutterApp/1.0 (contact@gyeongjugoflutter.com)',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('Saved ${entry.key} successfully.');
      } else {
        print('Failed to download ${entry.key}. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading ${entry.key}: $e');
    }
  }
  print('All real image downloads complete.');
}
