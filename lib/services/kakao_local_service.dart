import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoLocalService {
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search/category.json';

  static Future<List<Map<String, dynamic>>> fetchNearbyRestaurants(double lat, double lng, {int radius = 1000}) async {
    final apiKey = dotenv.env['KAKAO_REST_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('KAKAO_REST_API_KEY is missing');
      return [];
    }

    // FD6: Food (Restaurants)
    final url = '$_baseUrl?category_group_code=FD6&x=$lng&y=$lat&radius=$radius&sort=distance';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'KakaoAK $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;
        return documents.cast<Map<String, dynamic>>();
      } else {
        print('Kakao Local API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Kakao Local API Exception: $e');
      return [];
    }
  }
}
