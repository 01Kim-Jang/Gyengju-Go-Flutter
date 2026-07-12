import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final Map<String, String> spotFiles = {
  '경주_괘릉.jpg': 'Gyeongju Gwaereung Tomb 01.jpg',
  '감은사지.jpg': 'Korea-Gyeongju-Gameunsa temple pagodas-01.jpg',
  '경주_문무대왕릉.jpg': 'Gyeongju Tomb of King Munmu 02.jpg',
  '경주_무열왕릉.jpg': 'King Tae-Jong\'s Tomb 01.jpg',
  '경주_김유신묘.jpg': 'Gyeongju - Tomb of Kim Yu-sin - DSC01556.JPG',
  '경주_알영정.jpg': 'Gyeongju Poseokjeong 03.jpg',
  '경주_양동마을.jpg': 'Gyeongju Yangdong Folk Village-01.jpg',
  '경주_경주남산.jpg': 'Gyeongju Namsan Bodhisattva.jpg',
  '경주_천년고도_도심_답사길.jpg': 'Street of Hanok-styled houses in Gyeongju.jpg',
  '교촌마을.jpg': 'Gyeongju Gyochon Folk Village 03.jpg',
  '경주_토함산.jpg': 'Tohamsan summit.jpg',
  '경주_보문정.jpg': 'Gyeongju Bomun Lake 02.jpg',
  '경주_보문관광단지.jpg': 'Gyeongju Bomun Lake 02.jpg',
  '경주_세심마을.jpg': 'Traditional Korean village houses.jpg',
  '경주_도다리.jpg': 'Gyeongju traditional market 01.jpg',
  '경주_막걸리.jpg': 'Makgeolli in bowl.jpg',
};

Future<void> main() async {
  final dir = Directory('assets/images/spots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final headers = {
    'User-Agent': 'GyeongjuGOFlutterApp/1.0 (contact@gyeongjugoflutter.com)',
  };

  print('Resolving direct image URLs via Wikimedia API...');
  for (var entry in spotFiles.entries) {
    final localFilename = entry.key;
    final wikiFilename = entry.value;
    
    final apiUrl = 'https://commons.wikimedia.org/w/api.php?action=query&titles=File:$wikiFilename&prop=imageinfo&iiprop=url&format=json';
    print('Resolving $wikiFilename...');
    
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
            print('Found URL for $localFilename: $directUrl');
            
            // Download image
            print('Downloading image for $localFilename...');
            final imgRes = await http.get(Uri.parse(directUrl), headers: headers);
            if (imgRes.statusCode == 200) {
              final file = File('${dir.path}/$localFilename');
              await file.writeAsBytes(imgRes.bodyBytes);
              print('Saved $localFilename successfully!');
            } else {
              print('Failed to download image. Status: ${imgRes.statusCode}');
            }
          } else {
            print('No imageinfo found for $wikiFilename. Page may not exist.');
          }
        } else {
          print('No page found for $wikiFilename');
        }
      } else {
        print('API returned error: ${res.statusCode}');
      }
    } catch (e) {
      print('Error processing $localFilename: $e');
    }
  }
  print('All API-resolved image downloads complete.');
}
