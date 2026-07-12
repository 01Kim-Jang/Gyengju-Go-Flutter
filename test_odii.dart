import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testLang(String appLangCode) async {
  String odiiLang = 'en';
  if (appLangCode == 'ko') {
    odiiLang = 'ko';
  } else if (appLangCode == 'ja') {
    odiiLang = 'jp';
  } else if (appLangCode == 'zh-chs') {
    odiiLang = 'cn1';
  } else if (appLangCode == 'en') {
    odiiLang = 'en';
  } else {
    odiiLang = 'en';
  }

  final r = await http.get(Uri.parse('https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey=0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0&numOfRows=5000&pageNo=1&MobileOS=AND&MobileApp=App&_type=json&langCode=$odiiLang'));
  try {
    final parsed = jsonDecode(r.body);
    final items = parsed['response']['body']['items']['item'] as List;
    final g = items.where((i) {
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
    }).toList();
    if (appLangCode == 'zh-chs' && items.isNotEmpty) {
      print('=== cn1 sample items ===');
      for (int i = 0; i < (items.length > 10 ? 10 : items.length); i++) {
        print('Item $i: title=${items[i]['title']}, addr1=${items[i]['addr1']}, addr2=${items[i]['addr2']}');
      }
    }
    print('[$appLangCode (mapped: $odiiLang)] Total: ${items.length}, Filtered Gyeongju: ${g.length}');
    if (g.isNotEmpty) {
      print('  Sample: title=${g.first['title']}, addr1=${g.first['addr1']}, addr2=${g.first['addr2']}');
    }
  } catch (e) {
    print('[$appLangCode (mapped: $odiiLang)] Error: $e');
    print('[$appLangCode (mapped: $odiiLang)] Raw body: ${r.body.length > 500 ? r.body.substring(0, 500) : r.body}');
  }
}

void main() async {
  await testLang('ko');
  await testLang('en');
  await testLang('ja');
  await testLang('zh-chs');
  await testLang('vi');
  await testLang('th');
}
