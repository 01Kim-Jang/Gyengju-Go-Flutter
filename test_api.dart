import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final r = await http.get(Uri.parse('https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey=0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0&numOfRows=100&pageNo=1&MobileOS=AND&MobileApp=GyeongjuGo&_type=json&langCode=ko'));
  print(r.statusCode);
  if (r.body.length > 500) {
    print(r.body.substring(0, 500));
  } else {
    print(r.body);
  }
}
