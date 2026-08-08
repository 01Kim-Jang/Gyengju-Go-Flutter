import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final serviceKey = Platform.environment['ODII_SERVICE_KEY'];
  if (serviceKey == null || serviceKey.isEmpty) {
    stderr.writeln('ODII_SERVICE_KEY 환경변수를 설정하세요 (.env 참고).');
    exit(1);
  }
  final r = await http.get(Uri.parse('https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey=$serviceKey&numOfRows=10&pageNo=1&MobileOS=AND&MobileApp=App&_type=json&langCode=ko'));
  final data = jsonDecode(r.body);
  final items = data['response']['body']['items']['item'] as List;
  print(items.first.keys.toList());
}
