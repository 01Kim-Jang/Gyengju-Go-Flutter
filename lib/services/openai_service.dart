import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static Future<String> translateText(String text, String targetLang) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return text; // 키가 없으면 원본 반환

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Odii 언어 코드를 GPT 프롬프트용 언어 이름으로 변환
    String langName = 'English';
    switch (targetLang) {
      case 'ja':
        langName = 'Japanese';
        break;
      case 'zh-chs':
        langName = 'Simplified Chinese';
        break;
      case 'zh-cht':
        langName = 'Traditional Chinese';
        break;
      case 'ko':
        return text;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional tour guide translator. Translate the following text to $langName. Maintain historical terms where appropriate.',
            },
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        // UTF-8 디코딩 처리
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'];
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('OpenAI Exception: $e');
    }

    return text;
  }

  static Future<String> chatWithAI(
    String question,
    String targetLang, {
    double? lat,
    double? lng,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return "오류: OpenAI API Key가 설정되지 않았습니다.";

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    String langName = 'Korean';
    switch (targetLang) {
      case 'en':
        langName = 'English';
        break;
      case 'ja':
        langName = 'Japanese';
        break;
      case 'zh-chs':
        langName = 'Simplified Chinese';
        break;
      case 'vi':
        langName = 'Vietnamese';
        break;
      case 'th':
        langName = 'Thai';
        break;
    }

    String locationContext = lat != null && lng != null
        ? "The user's current GPS location is Latitude: $lat, Longitude: $lng (in Gyeongju, South Korea)."
        : "The user is in Gyeongju, South Korea.";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a friendly and knowledgeable AI tour guide for Gyeongju, South Korea. '
                  '$locationContext '
                  'Provide recommendations for nearby restaurants, routes, or historical facts based on their location if asked. '
                  'Always reply in $langName. '
                  'CRITICAL: If you recommend any specific restaurant, cafe, or tourist spot, you MUST append a tag in the format `[ROUTE:Name,Latitude,Longitude]` for EACH recommended place so the app can render get-directions buttons. For example, if you suggest Bulguksa, append `[ROUTE:Bulguksa Temple,35.7899,129.3320]`. If you suggest multiple places, append multiple tags, e.g., `[ROUTE:PlaceA,LatA,LngA][ROUTE:PlaceB,LatB,LngB]`. Make sure the coordinates are highly accurate for Gyeongju.',
            },
            {'role': 'user', 'content': question},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'];
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return "오류가 발생했습니다. 나중에 다시 시도해주세요.";
      }
    } catch (e) {
      print('OpenAI Exception: $e');
      return "네트워크 오류가 발생했습니다.";
    }
  }

  // 장소 이름만으로 역사적 배경(도슨트 스크립트) 자동 생성
  static Future<String> generateDocentScript(String title) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return 'API 키가 설정되지 않았습니다.';

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 경주 역사 여행 가이드입니다. 제공된 명소에 대해 3~4문장 분량의 역사적 배경과 흥미로운 설명을 한국어로 작성해주세요. 관광객에게 설명하듯 친절하고 부드러운 어조를 사용하세요.',
            },
            {'role': 'user', 'content': title},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      }
    } catch (e) {
      print('OpenAI Docent Error: $e');
    }

    return '현재 이 장소에 대한 도슨트 정보를 불러올 수 없습니다.';
  }

  // 4. 주변 음식점 다국어 번역
  static Future<List<Map<String, dynamic>>> translateRestaurants(
    List<Map<String, dynamic>> restaurants,
    String targetLang,
  ) async {
    if (targetLang == 'ko' || restaurants.isEmpty) return restaurants;

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return restaurants;

    String langName = 'English';
    switch (targetLang) {
      case 'ja': langName = 'Japanese'; break;
      case 'zh-chs': langName = 'Simplified Chinese'; break;
      case 'zh-cht': langName = 'Traditional Chinese'; break;
      case 'vi': langName = 'Vietnamese'; break;
      case 'th': langName = 'Thai'; break;
    }

    try {
      final List<Map<String, String>> itemsToTranslate = restaurants.map((r) => {
        'name': r['place_name']?.toString() ?? '',
        'category': r['category_name']?.toString() ?? ''
      }).toList();

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'response_format': { 'type': 'json_object' },
          'messages': [
            {
              'role': 'system',
              'content': 'You are a translator. Translate the "name" and "category" of the provided JSON array of restaurants into $langName. '
                         'Return a JSON object with a single key "translated" containing the translated array of objects with "name" and "category".'
            },
            {'role': 'user', 'content': jsonEncode(itemsToTranslate)},
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final translatedJson = jsonDecode(content);
        final translatedList = translatedJson['translated'] as List;

        List<Map<String, dynamic>> result = [];
        for (int i = 0; i < restaurants.length; i++) {
          final translatedItem = translatedList.length > i ? translatedList[i] : null;
          final mapItem = Map<String, dynamic>.from(restaurants[i]);
          if (translatedItem != null) {
            mapItem['place_name'] = translatedItem['name'];
            mapItem['category_name'] = translatedItem['category'];
          }
          result.add(mapItem);
        }
        return result;
      }
    } catch (e) {
      print('OpenAI Translate Restaurants Error: $e');
    }

    return restaurants;
  }
}

