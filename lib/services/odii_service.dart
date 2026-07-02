import 'dart:convert';
import 'package:http/http.dart' as http;

class OdiiService {
  // 사용자님이 제공한 한국관광공사 Odii API 키
  static const String _serviceKey =
      '0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0';
  static const String _baseUrl = 'https://apis.data.go.kr/B551011/Odii';

  // 1. 테마 기반 스팟 정보 조회 (경주)
  static Future<List<Map<String, dynamic>>> fetchGyeongjuSpots(
    String langCode,
  ) async {
    // Convert generic language code to Odii specific code if needed
    String odiiLang = langCode;
    if (langCode == 'zh') odiiLang = 'zh-hans';
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
                } else {
                  mapItem['firstimage'] = mapItem['imageUrl'] != ''
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
      print('Odii API Error (Spots): $e');
    }

    // API 장애 또는 결과가 없을 때를 대비한 기본 경주 명소 데이터
    return [
      {'title': '첨성대', 'mapX': '129.219062', 'mapY': '35.834710'},
      {'title': '동궁과 월지 (안압지)', 'mapX': '129.2266', 'mapY': '35.8348'},
      {'title': '불국사', 'mapX': '129.3320', 'mapY': '35.7899'},
    ];
  }

  // 2. 오디오 도슨트 스크립트 조회 (Odii API 상세조회 대체)
  static Future<Map<String, dynamic>?> fetchAudioDocent(String title) async {
    return {
      'title': title,
      'script':
          '이곳 $title은(는) 신라의 천년 역사가 숨쉬는 대표적인 명소입니다. 옛 조상들의 지혜와 숨결을 느껴보세요.',
    };
  }
}
