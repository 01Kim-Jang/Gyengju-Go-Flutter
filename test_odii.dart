import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final String _serviceKey = '0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0';
  const String _baseUrl = 'https://apis.data.go.kr/B551011/Odii';

  final url2 = Uri.parse('$_baseUrl/searchList'
      '?serviceKey=$_serviceKey'
      '&numOfRows=1'
      '&pageNo=1'
      '&MobileOS=AND'
      '&MobileApp=GyeongjuGo'
      '&_type=json'
      '&keyword=경주 불국사'
      '&langCode=ko');

  try {
    final response2 = await http.get(url2);
    print('Docent Search Status: ${response2.statusCode}');
    if (response2.body.length > 500) {
      print('Docent Body: ${response2.body.substring(0, 500)}...');
    } else {
      print('Docent Body: ${response2.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
