import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final Map<String, String> finalSpotFiles = {
  '경주_괘릉.jpg': '원성왕릉.jpg',
  '감은사지.jpg': 'Korea-Gyeongju-Gameunsa temple pagodas-01.jpg',
  '경주_문무대왕릉.jpg': 'Tomb of King Munmu(문무대왕릉).jpg',
  '경주_무열왕릉.jpg': '경주 무열왕릉.jpg',
  '경주_김유신묘.jpg': 'Korea-Gyeongju-Tomb of General Kim Yusin-01.jpg',
  '경주_알영정.jpg': 'Korea south silla poseokjeong.jpg',
  '경주_양동마을.jpg': '2007-Korea-Gyeongju-Yangdong Village-01.jpg',
  '경주_경주남산.jpg': 'Namsan (Gyeongju).jpg',
  '경주_천년고도_도심_답사길.jpg': 'Gyochon Traditional Village 02.jpg',
  '교촌마을.jpg': 'Gyochon Traditional Village 01.jpg',
  '경주_토함산.jpg': 'Tohamsan.jpg',
  '경주_보문정.jpg': 'Korea-Gyeongju-Bomun Lake in autumn-01.jpg',
  '경주_보문관광단지.jpg': 'Korea-Gyeongju-Bomun Lake in autumn-02.jpg',
  '경주_세심마을.jpg': '2007-Korea-Gyeongju-Yangdong Village-03.jpg',
  '경주_도다리.jpg': 'Namsan and paddy fields in Gyeongju.jpg',
  '경주_막걸리.jpg': 'View of Gyeongju-Korea-01.jpg',
};

Future<void> main() async {
  final dir = Directory('assets/images/spots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final headers = {
    'User-Agent': 'GyeongjuGOFlutterApp/1.0 (contact@gyeongjugoflutter.com)',
  };

  print('Downloading final verified real images via Wikimedia API...');
  for (var entry in finalSpotFiles.entries) {
    final localFilename = entry.key;
    final wikiFilename = entry.value;
    
    final apiUrl = 'https://commons.wikimedia.org/w/api.php?action=query&titles=File:$wikiFilename&prop=imageinfo&iiprop=url&format=json';
    print('Resolving URL for $wikiFilename...');
    
    try {
      final res = await http.get(Uri.parse(apiUrl), headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final pages = json['query']['pages'] as Map;
        if (pages.isNotEmpty) {
          final pageId = pages.keys.first;
          final pageData = pages[pageId] as Map;
          if (pageData.containsKey('imageinfo')) {
            final directUrl = pageData['imageinfo'][0]['url'] as String;
            print('Found URL: $directUrl');
            
            print('Downloading $localFilename...');
            final imgRes = await http.get(Uri.parse(directUrl), headers: headers);
            if (imgRes.statusCode == 200) {
              final file = File('${dir.path}/$localFilename');
              await file.writeAsBytes(imgRes.bodyBytes);
              print('Saved $localFilename successfully!');
            } else {
              print('Failed download for $localFilename. Status: ${imgRes.statusCode}');
            }
          } else {
            print('No imageinfo for $wikiFilename');
          }
        } else {
          print('No page found for $wikiFilename');
        }
      } else {
        print('API Error: ${res.statusCode}');
      }
    } catch (e) {
      print('Error processing $localFilename: $e');
    }
  }
  print('All final image downloads complete.');
}
