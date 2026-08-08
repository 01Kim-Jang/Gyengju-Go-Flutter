import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class BusStop {
  final String nodeId;
  final String nodeName;
  final String cityCode;
  final double lat;
  final double lng;
  final double distanceM;

  BusStop({
    required this.nodeId,
    required this.nodeName,
    required this.cityCode,
    required this.lat,
    required this.lng,
    required this.distanceM,
  });
}

class BusArrival {
  final String routeNo;
  final String vehicleType;
  final int arrivalSeconds;
  final int stopsAway;

  BusArrival({
    required this.routeNo,
    required this.vehicleType,
    required this.arrivalSeconds,
    required this.stopsAway,
  });

  int get arrivalMinutes => (arrivalSeconds / 60).ceil();
}

class NearestStopArrivals {
  final BusStop stop;
  final List<BusArrival> arrivals;

  NearestStopArrivals({required this.stop, required this.arrivals});
}

// 국토교통부(TAGO) 버스정류소정보/버스도착정보 OpenAPI 연동.
// data.go.kr에서 두 API(버스정류소정보 15098534, 버스도착정보 15098530)를
// 별도로 활용신청해야 하며, 인증키는 .env의 TAGO_SERVICE_KEY(없으면 ODII_SERVICE_KEY)를 사용한다.
class TagoService {
  static String get _serviceKey {
    if (!dotenv.isInitialized) return '';
    final key = dotenv.env['TAGO_SERVICE_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return dotenv.env['ODII_SERVICE_KEY'] ?? '';
  }

  static const String _sttnBaseUrl = 'https://apis.data.go.kr/1613000/BusSttnInfoInqireService';
  static const String _arvlBaseUrl = 'https://apis.data.go.kr/1613000/ArvlInfoInqireService';

  // 1. 좌표 기반 근접 정류소 목록 조회 (citycode가 응답에 함께 내려오므로 별도 도시코드 조회 불필요)
  static Future<List<BusStop>> fetchNearbyStops(double lat, double lng) async {
    final key = _serviceKey;
    if (key.isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_sttnBaseUrl/getCrdntPrxmtSttnList'
        '?serviceKey=$key'
        '&gpsLati=$lat'
        '&gpsLong=$lng'
        '&numOfRows=10'
        '&pageNo=1'
        '&_type=json',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['response']?['body']?['items']?['item'];
      if (items == null) return [];
      final list = items is List ? items : [items];

      final stops = list
          .map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            final stopLat = double.tryParse(m['gpslati']?.toString() ?? '') ?? 0;
            final stopLng = double.tryParse(m['gpslong']?.toString() ?? '') ?? 0;
            return BusStop(
              nodeId: m['nodeid']?.toString() ?? '',
              nodeName: m['nodenm']?.toString() ?? '',
              cityCode: m['citycode']?.toString() ?? '',
              lat: stopLat,
              lng: stopLng,
              distanceM: Geolocator.distanceBetween(lat, lng, stopLat, stopLng),
            );
          })
          .where((s) => s.nodeId.isNotEmpty && s.cityCode.isNotEmpty)
          .toList();

      stops.sort((a, b) => a.distanceM.compareTo(b.distanceM));
      return stops;
    } catch (e) {
      print('TAGO API Error (Nearby Stops): $e');
      return [];
    }
  }

  // 2. 정류소별 실시간 버스 도착예정정보 조회
  static Future<List<BusArrival>> fetchArrivals(String cityCode, String nodeId) async {
    final key = _serviceKey;
    if (key.isEmpty || cityCode.isEmpty || nodeId.isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_arvlBaseUrl/getSttnAcctoArvlPrearngeInfoList'
        '?serviceKey=$key'
        '&cityCode=$cityCode'
        '&nodeId=$nodeId'
        '&numOfRows=10'
        '&pageNo=1'
        '&_type=json',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['response']?['body']?['items']?['item'];
      if (items == null) return [];
      final list = items is List ? items : [items];

      final arrivals = list
          .map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            return BusArrival(
              routeNo: m['routeno']?.toString() ?? '',
              vehicleType: m['vehicletp']?.toString() ?? '',
              arrivalSeconds: int.tryParse(m['arrtime']?.toString() ?? '') ?? 0,
              stopsAway: int.tryParse(m['arrprevstationcnt']?.toString() ?? '') ?? 0,
            );
          })
          .where((a) => a.routeNo.isNotEmpty)
          .toList();

      arrivals.sort((a, b) => a.arrivalSeconds.compareTo(b.arrivalSeconds));
      return arrivals;
    } catch (e) {
      print('TAGO API Error (Arrivals): $e');
      return [];
    }
  }

  // 3. 주어진 좌표에서 가장 가까운 "실제로 도착 예정 버스가 있는" 정류소를 찾아 바로 반환.
  // 정류소는 있지만 도착 예정 버스가 없는 경우(막차 종료 등)를 대비해 가까운 순으로 최대 3곳까지 시도한다.
  static Future<NearestStopArrivals?> fetchNearestStopArrivals(double lat, double lng) async {
    final stops = await fetchNearbyStops(lat, lng);
    if (stops.isEmpty) return null;

    for (final stop in stops.take(3)) {
      final arrivals = await fetchArrivals(stop.cityCode, stop.nodeId);
      if (arrivals.isNotEmpty) {
        return NearestStopArrivals(stop: stop, arrivals: arrivals);
      }
    }
    return NearestStopArrivals(stop: stops.first, arrivals: const []);
  }
}
