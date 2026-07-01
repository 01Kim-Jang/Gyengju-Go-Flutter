import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  final envStr = await File('.env').readAsString();
  final tokenLine = envStr.split('\n').firstWhere((l) => l.startsWith('MAPBOX_ACCESS_TOKEN='));
  final token = tokenLine.split('=')[1].trim();

  final url = Uri.parse('https://api.mapbox.com/styles/v1/jhjang0703/cmr09ioq7002e01stcrp2d9cq?access_token=$token');
  final r = await http.get(url);
  final data = jsonDecode(r.body);
  final layers = data['layers'] as List;
  for (var l in layers) {
    if (l['id'].contains('building') || l['id'].contains('poi') || l['id'].contains('label')) {
      print(l['id']);
    }
  }
}
