import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoLocalService {
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search/category.json';

  static Future<List<Map<String, dynamic>>> fetchNearbyRestaurants(double lat, double lng, {int radius = 1000}) {
    // FD6: Food (Restaurants)
    return fetchNearbyByCategory('FD6', lat, lng, radius: radius);
  }

  // PM9: Pharmacy(약국), HP8: Hospital(병원)
  static Future<List<Map<String, dynamic>>> fetchNearbyPharmacies(double lat, double lng, {int radius = 1500}) {
    return fetchNearbyByCategory('PM9', lat, lng, radius: radius);
  }

  static Future<List<Map<String, dynamic>>> fetchNearbyHospitals(double lat, double lng, {int radius = 1500}) {
    return fetchNearbyByCategory('HP8', lat, lng, radius: radius);
  }

  static Future<List<Map<String, dynamic>>> fetchNearbyByCategory(
    String categoryGroupCode,
    double lat,
    double lng, {
    int radius = 1000,
  }) async {
    final apiKey = dotenv.env['KAKAO_REST_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('KAKAO_REST_API_KEY is missing');
      return [];
    }

    final url = '$_baseUrl?category_group_code=$categoryGroupCode&x=$lng&y=$lat&radius=$radius&sort=distance';

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
        debugPrint('Kakao Local API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Kakao Local API Exception: $e');
      return [];
    }
  }
}
