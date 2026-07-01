import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final r = await http.get(Uri.parse('https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey=0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0&numOfRows=5000&pageNo=1&MobileOS=AND&MobileApp=App&_type=json'));
  final items = jsonDecode(r.body)['response']['body']['items']['item'] as List;
  final g = items.where((i) => i['addr1']?.contains('경주') == true || i['addr2']?.contains('경주') == true).toList();
  print('Gyeongju spots: ${g.length}');
}
