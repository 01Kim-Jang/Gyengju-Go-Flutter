import 'dart:convert';
import 'package:http/http.dart' as http;

final List<String> keywords = [
  'Gwaereung',
  'King Munmu',
  'Poseokjeong',
  'Tohamsan',
  'Bomunjeong',
];

Future<void> main() async {
  final headers = {
    'User-Agent': 'GyeongjuGOFlutterApp/1.0 (contact@gyeongjugoflutter.com)',
  };

  print('Searching files on Wikimedia Commons:\n');
  for (var kw in keywords) {
    final url = 'https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch=$kw&srnamespace=6&srlimit=5&format=json';
    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['query']['search'] as List;
        print('=== Keyword: $kw ===');
        for (var result in results) {
          print(' - ${result['title']}');
        }
        print('');
      } else {
        print('Error for $kw: ${res.statusCode}');
      }
    } catch (e) {
      print('Failed for $kw: $e');
    }
  }
}
