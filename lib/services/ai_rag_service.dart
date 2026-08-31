import 'package:geolocator/geolocator.dart';
import '../data/spots_db.dart';

// AI 비서(챗봇)가 답변하기 전에, GPT의 일반 지식 대신 팀이 직접 검수한
// SpotsDB(명소별 사실/팁)에서 관련 있는 명소를 찾아 시스템 프롬프트에 붙여주는
// 아주 가벼운 RAG(Retrieval-Augmented Generation). 명소 수가 40여 개뿐이라
// 별도 벡터 DB 없이, (1) 사용자 질문에 이름이 언급된 명소와 (2) 사용자와
// 가까운 명소를 함께 후보로 모아 점수화하는 방식으로 충분하다.
class AiRagService {
  static const int _maxSpots = 4;
  static const double _nearbyRadiusM = 3000;

  static String buildContext({
    required String question,
    required String lang,
    required List<Map<String, dynamic>> spotsData,
    double? userLat,
    double? userLng,
  }) {
    final q = question.toLowerCase();
    final candidates = <_ScoredSpot>[];
    final seenNames = <String>{};

    for (final spot in spotsData) {
      final rawTitle = spot['title']?.toString() ?? '';
      if (rawTitle.isEmpty) continue;
      final detail = SpotsDB.get(rawTitle);
      if (detail == null) continue;
      if (!seenNames.add(detail.getName('ko'))) continue; // 중복 명소 제거

      final mentioned = detail.names.values
          .any((name) => name.isNotEmpty && q.contains(name.toLowerCase()));

      double? distanceM;
      final lat = double.tryParse(spot['mapY']?.toString() ?? '');
      final lng = double.tryParse(spot['mapX']?.toString() ?? '');
      if (userLat != null && userLng != null && lat != null && lng != null) {
        distanceM = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      }

      final isNearby = distanceM != null && distanceM <= _nearbyRadiusM;
      if (!mentioned && !isNearby) continue;

      // 언급된 명소가 최우선, 그다음은 가까운 순.
      final score = mentioned ? -1.0 : distanceM!;
      candidates.add(_ScoredSpot(detail, score));
    }

    if (candidates.isEmpty) return '';

    candidates.sort((a, b) => a.score.compareTo(b.score));
    final top = candidates.take(_maxSpots);

    final buffer = StringBuffer();
    for (final c in top) {
      final name = c.detail.getName(lang);
      final fact = c.detail.getFact(lang);
      final tip = c.detail.getTip(lang);
      buffer.writeln('- $name: $fact (Tip: $tip)');
    }
    return buffer.toString();
  }
}

class _ScoredSpot {
  final SpotDetail detail;
  final double score;
  _ScoredSpot(this.detail, this.score);
}
