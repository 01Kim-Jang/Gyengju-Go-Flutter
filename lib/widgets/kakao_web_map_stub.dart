import 'package:flutter/material.dart';

/// 웹이 아닌 플랫폼용 스텁. 실제 구현(kakao_web_map.dart)은 dart:js_interop/dart:ui_web을
/// 쓰기 때문에 안드로이드에서는 컴파일조차 되지 않는다. 모바일은 kIsWeb 분기로
/// kakao_map_plugin을 쓰므로 이 위젯이 실제로 그려질 일은 없다.
class KakaoWebMap extends StatelessWidget {
  const KakaoWebMap({
    super.key,
    required this.spots,
    required this.displayNames,
    this.targetTitle,
    this.routeCoordinates,
    this.navigationMode,
    this.myLocation,
    required this.onMarkerTap,
    this.onControllerReady,
  });

  final List<Map<String, dynamic>> spots;
  final Map<String, String> displayNames;
  final String? targetTitle;
  final List<List<double>>? routeCoordinates;
  final String? navigationMode;
  final Map<String, double>? myLocation;
  final void Function(String title) onMarkerTap;
  final void Function(void Function(double lat, double lng, {int? level}) panTo)? onControllerReady;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
