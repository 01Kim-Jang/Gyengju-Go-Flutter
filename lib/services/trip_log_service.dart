import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 여행 보고서(일지/회고) 기능용 로컬 기록 서비스.
// 앱에 지금까지 로컬 저장 계층이 전혀 없어서(재시작하면 진행 상황이 다 날아감),
// 날짜별로 GPS 궤적(breadcrumb)과 포켓스탑 방문 기록을 SharedPreferences에
// JSON으로 저장한다. Firebase 연동 여부와 무관하게 오프라인에서도 동작한다.
class TripBreadcrumb {
  final double lat;
  final double lng;
  final DateTime timestamp;

  TripBreadcrumb({required this.lat, required this.lng, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        't': timestamp.toIso8601String(),
      };

  factory TripBreadcrumb.fromJson(Map<String, dynamic> json) => TripBreadcrumb(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        timestamp: DateTime.parse(json['t'] as String),
      );
}

class TripVisit {
  final String spotTitle;
  final double lat;
  final double lng;
  final DateTime timestamp;

  TripVisit({required this.spotTitle, required this.lat, required this.lng, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'spotTitle': spotTitle,
        'lat': lat,
        'lng': lng,
        't': timestamp.toIso8601String(),
      };

  factory TripVisit.fromJson(Map<String, dynamic> json) => TripVisit(
        spotTitle: json['spotTitle']?.toString() ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        timestamp: DateTime.parse(json['t'] as String),
      );
}

class TripLogService {
  static const String _breadcrumbsKey = 'trip_breadcrumbs_v1';
  static const String _visitsKey = 'trip_visits_v1';

  static String dateKeyFor(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static Future<Map<String, dynamic>> _readMap(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (e) {
      debugPrint('TripLogService._readMap($key) Error: $e');
      return {};
    }
  }

  static Future<void> _writeMap(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('TripLogService._writeMap($key) Error: $e');
    }
  }

  static Future<void> appendBreadcrumb(double lat, double lng, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final key = dateKeyFor(now);
    final data = await _readMap(_breadcrumbsKey);
    final dayList = List<dynamic>.from(data[key] ?? []);
    dayList.add(TripBreadcrumb(lat: lat, lng: lng, timestamp: now).toJson());
    data[key] = dayList;
    await _writeMap(_breadcrumbsKey, data);
  }

  static Future<void> appendVisit(String spotTitle, double lat, double lng, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final key = dateKeyFor(now);
    final data = await _readMap(_visitsKey);
    final dayList = List<dynamic>.from(data[key] ?? []);
    dayList.add(TripVisit(spotTitle: spotTitle, lat: lat, lng: lng, timestamp: now).toJson());
    data[key] = dayList;
    await _writeMap(_visitsKey, data);
  }

  // 기록이 존재하는 날짜(YYYY-MM-DD) 목록을 최신순으로 반환한다.
  static Future<List<String>> listDaysWithData() async {
    final breadcrumbs = await _readMap(_breadcrumbsKey);
    final visits = await _readMap(_visitsKey);
    final days = <String>{...breadcrumbs.keys, ...visits.keys}.toList();
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  static Future<List<TripBreadcrumb>> getBreadcrumbs(String dayKey) async {
    final data = await _readMap(_breadcrumbsKey);
    final list = List<dynamic>.from(data[dayKey] ?? []);
    return list.map((e) => TripBreadcrumb.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  static Future<List<TripVisit>> getVisits(String dayKey) async {
    final data = await _readMap(_visitsKey);
    final list = List<dynamic>.from(data[dayKey] ?? []);
    return list.map((e) => TripVisit.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  // 전체 여행 기간을 하나로 합친 궤적/방문기록 (날짜 구분 없이 시간순 정렬).
  static Future<List<TripBreadcrumb>> getAllBreadcrumbs() async {
    final data = await _readMap(_breadcrumbsKey);
    final all = <TripBreadcrumb>[];
    for (final dayList in data.values) {
      for (final e in List<dynamic>.from(dayList as List)) {
        all.add(TripBreadcrumb.fromJson(Map<String, dynamic>.from(e as Map)));
      }
    }
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }

  static Future<List<TripVisit>> getAllVisits() async {
    final data = await _readMap(_visitsKey);
    final all = <TripVisit>[];
    for (final dayList in data.values) {
      for (final e in List<dynamic>.from(dayList as List)) {
        all.add(TripVisit.fromJson(Map<String, dynamic>.from(e as Map)));
      }
    }
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }

  // 궤적 포인트를 순서대로 이어 총 이동거리(m)를 계산 (하버사인 공식).
  static double totalDistanceMeters(List<TripBreadcrumb> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _distanceMeters(points[i - 1].lat, points[i - 1].lng, points[i].lat, points[i].lng);
    }
    return total;
  }

  static double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742000 * math.asin(math.sqrt(a)); // 2 * R(m) * asin(sqrt(a))
  }
}
