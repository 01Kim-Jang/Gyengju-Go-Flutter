import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final String serviceKey = '0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0';
final String baseUrl = 'https://apis.data.go.kr/B551011/Odii';

Future<List<Map<String, dynamic>>> fetchSpots(String odiiLang) async {
  final url = Uri.parse(
    '$baseUrl/themeBasedList'
    '?serviceKey=$serviceKey'
    '&numOfRows=5000'
    '&pageNo=1'
    '&MobileOS=AND'
    '&MobileApp=GyeongjuGo'
    '&_type=json'
    '&langCode=$odiiLang',
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final items = data['response']?['body']?['items']?['item'] as List<dynamic>?;
    if (items != null) {
      final gyeongjuSpots = items.where((i) {
        final addr1 = i['addr1']?.toString().toLowerCase() ?? '';
        final addr2 = i['addr2']?.toString().toLowerCase() ?? '';
        final title = i['title']?.toString().toLowerCase() ?? '';
        return addr1.contains('경주') ||
            addr2.contains('경주') ||
            addr1.contains('gyeongju') ||
            addr2.contains('gyeongju') ||
            title.contains('gyeongju') ||
            title.contains('경주') ||
            addr1.contains('キョンジュ') ||
            addr2.contains('キョンジュ') ||
            title.contains('キョンジュ') ||
            addr1.contains('慶州') ||
            addr2.contains('慶州') ||
            title.contains('慶州') ||
            addr1.contains('庆州') ||
            addr2.contains('庆州') ||
            title.contains('庆州') ||
            addr1.contains('kyongju') ||
            addr2.contains('kyongju') ||
            title.contains('kyongju');
      }).map((item) {
        final mapItem = Map<String, dynamic>.from(item);
        String title = mapItem['title']?.toString() ?? '';
        
        // Match images (same as current OdiiService logic)
        if (title.contains('동궁과 월지') || title.contains('Donggung') || title.contains('雁鴨池') || title.contains('东宫')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg';
        } else if (title.contains('불국사') || title.contains('Bulguksa') || title.contains('仏国寺') || title.contains('佛国寺')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056006730100.jpg';
        } else if (title.contains('계림') || title.contains('Gyerim') || title.contains('鷄林') || title.contains('鸡林')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055998188100.jpg';
        } else if (title.contains('월성') || title.contains('Wolseong') || title.contains('月城')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055990263600.jpg';
        } else if (title.contains('박물관') || title.contains('Museum') || title.contains('博物館')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056018318800.jpg';
        } else if (title.contains('황룡사') || title.contains('Hwangnyongsa') || title.contains('皇龍寺') || title.contains('皇龙寺')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056001272600.jpg';
        } else if (title.contains('문무대왕') || title.contains('Munmu') || title.contains('文武')) {
          mapItem['firstimage'] = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056024317800.jpg';
        } else {
          mapItem['firstimage'] = (mapItem['imageUrl'] != null && mapItem['imageUrl'] != '')
              ? mapItem['imageUrl']
              : 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg';
        }
        
        // Keep only required keys to minimize file size
        return {
          'title': mapItem['title'] ?? '',
          'mapX': mapItem['mapX'] ?? '',
          'mapY': mapItem['mapY'] ?? '',
          'firstimage': mapItem['firstimage'] ?? '',
          'overview': mapItem['overview'] ?? '',
        };
      }).toList();
      return gyeongjuSpots;
    }
  }
  return [];
}

void main() async {
  print('Fetching spots for ko...');
  final koSpots = await fetchSpots('ko');
  print('Fetching spots for en...');
  final enSpots = await fetchSpots('en');
  print('Fetching spots for jp...');
  final jpSpots = await fetchSpots('jp');
  print('Fetching spots for cn1...');
  final cn1Spots = await fetchSpots('cn1');

  final buffer = StringBuffer();
  buffer.writeln('// Generated file. Do not edit manually.');
  buffer.writeln('class PreloadedSpots {');
  buffer.writeln('  static const Map<String, List<Map<String, String>>> data = {');
  
  void writeSpotsList(String lang, List<Map<String, dynamic>> spots) {
    buffer.writeln('    \'$lang\': [');
    for (var s in spots) {
      buffer.writeln('      {');
      buffer.writeln('        \'title\': \'${s['title'].replaceAll("'", "\\'")}\',');
      buffer.writeln('        \'mapX\': \'${s['mapX']}\',');
      buffer.writeln('        \'mapY\': \'${s['mapY']}\',');
      buffer.writeln('        \'firstimage\': \'${s['firstimage']}\',');
      buffer.writeln('        \'overview\': \'${(s['overview'] ?? '').replaceAll("'", "\\'")}\',');
      buffer.writeln('      },');
    }
    buffer.writeln('    ],');
  }

  writeSpotsList('ko', koSpots);
  writeSpotsList('en', enSpots);
  writeSpotsList('ja', jpSpots);
  writeSpotsList('zh-chs', cn1Spots);
  
  buffer.writeln('  };');
  buffer.writeln('}');

  final outputFile = File('lib/data/preloaded_spots.dart');
  await outputFile.writeAsString(buffer.toString());
  print('Preloaded spots file created successfully at ${outputFile.path}!');
}
