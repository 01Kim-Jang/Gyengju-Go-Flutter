import 'dart:convert';
import 'package:http/http.dart' as http;

final List<String> categories = [
  'Category:Tomb of Kim Yu-sin',
  'Category:Tomb of King Muyeol',
  'Category:Gyochon Village',
  'Category:Yangdong Folk Village',
  'Category:Gwaereung',
  'Category:Gameunsa',
  'Category:Namsan (Gyeongju)',
  'Category:Seokguram',
  'Category:Bomun Lake',
];

Future<void> main() async {
  final headers = {
    'User-Agent': 'GyeongjuGOFlutterApp/1.0 (contact@gyeongjugoflutter.com)',
  };

  print('Listing files in Wikimedia Commons categories:\n');
  for (var cat in categories) {
    final url = 'https://commons.wikimedia.org/w/api.php?action=query&list=categorymembers&cmtitle=$cat&cmtype=file&cmlimit=10&format=json';
    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final members = data['query']['categorymembers'] as List;
        print('=== Category: $cat ===');
        for (var member in members) {
          print(' - ${member['title']}');
        }
        print('');
      } else {
        print('Error for $cat: ${res.statusCode}');
      }
    } catch (e) {
      print('Failed for $cat: $e');
    }
  }
}
