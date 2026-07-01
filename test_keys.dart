import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final r = await http.get(Uri.parse('https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey=0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0&numOfRows=10&pageNo=1&MobileOS=AND&MobileApp=App&_type=json&langCode=ko'));
  final data = jsonDecode(r.body);
  final items = data['response']['body']['items']['item'] as List;
  print(items.first.keys.toList());
}
