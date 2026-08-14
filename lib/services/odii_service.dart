import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/preloaded_spots.dart';

class OdiiService {
  static String get _serviceKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['ODII_SERVICE_KEY'] ?? '';
  }

  static const String _baseUrl = 'https://apis.data.go.kr/B551011/Odii';

  // 1. 테마 기반 스팟 정보 조회 (경주)
  static Future<List<Map<String, dynamic>>> fetchGyeongjuSpots(
    String langCode,
  ) async {
    // 1. Map to supported preloaded language codes
    String odiiLang = 'en';
    if (langCode == 'ko') {
      odiiLang = 'ko';
    } else if (langCode == 'ja') {
      odiiLang = 'ja';
    } else if (langCode == 'zh-chs' || langCode == 'zh') {
      odiiLang = 'zh-chs';
    } else {
      odiiLang = 'en'; // fallback for vi, th, etc.
    }

    // 2. Return preloaded data instantly to increase loading speed
    if (PreloadedSpots.data.containsKey(odiiLang)) {
      return PreloadedSpots.data[odiiLang]!
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
    }

    final url = Uri.parse(
      '$_baseUrl/themeBasedList'
      '?serviceKey=$_serviceKey'
      '&numOfRows=5000'
      '&pageNo=1'
      '&MobileOS=AND'
      '&MobileApp=GyeongjuGo'
      '&_type=json'
      '&langCode=$odiiLang',
    ); // areaCode와 themeCd는 에러를 유발하므로 제거

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items =
            data['response']?['body']?['items']?['item'] as List<dynamic>?;
        if (items != null) {
          // 경주시 데이터만 필터링
          final gyeongjuSpots = items
              .where((i) {
                final addr1 = i['addr1']?.toString().toLowerCase() ?? '';
                final addr2 = i['addr2']?.toString().toLowerCase() ?? '';
                final title = i['title']?.toString().toLowerCase() ?? '';
                return addr1.contains('경주') ||
                    addr2.contains('경주') ||
                    addr1.contains('gyeongju') ||
                    addr2.contains('gyeongju') ||
                    title.contains('gyeongju') ||
                    title.contains('경주') ||
                    addr1.contains('キョンジュ') ||
                    addr2.contains('キョンジュ') ||
                    title.contains('キョンジュ');
              })
              .map((item) {
                final mapItem = Map<String, dynamic>.from(item);
                // Odii API는 imageUrl을 주지만 비어있는 경우가 많으므로 임시 목업 이미지 주입 (BE 연동 전 FE 테스트용)
                String title = mapItem['title']?.toString() ?? '';
                if (title.contains('동궁과 월지') ||
                    title.contains('Donggung') ||
                    title.contains('雁鴨池')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg';
                } else if (title.contains('불국사') ||
                    title.contains('Bulguksa')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056006730100.jpg';
                } else if (title.contains('계림') || title.contains('Gyerim')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055998188100.jpg';
                } else if (title.contains('월성') || title.contains('Wolseong')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055990263600.jpg';
                } else if (title.contains('박물관') || title.contains('Museum')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056018318800.jpg';
                } else if (title.contains('황룡사') || title.contains('Hwangnyongsa')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056001272600.jpg';
                } else if (title.contains('문무대왕') || title.contains('Munmu')) {
                  mapItem['firstimage'] =
                      'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056024317800.jpg';
                } else {
                  mapItem['firstimage'] = (mapItem['imageUrl'] != null && mapItem['imageUrl'] != '')
                      ? mapItem['imageUrl']
                      : 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg'; // Default fallback
                }
                return mapItem;
              })
              .toList();

          if (gyeongjuSpots.isNotEmpty) {
            return gyeongjuSpots;
          }
        }
      }
    } catch (e) {
      debugPrint('Odii API Error (Spots): $e');
    }

    // API 장애 또는 결과가 없을 때를 대비한 기본 경주 명소 데이터
    return [
      {'title': '첨성대', 'mapX': '129.219062', 'mapY': '35.834710'},
      {'title': '동궁과 월지 (안압지)', 'mapX': '129.2266', 'mapY': '35.8348'},
      {'title': '불국사', 'mapX': '129.3320', 'mapY': '35.7899'},
    ];
  }

}
