import 'package:flutter/material.dart';
import '../widgets/bus_arrival_sheet.dart';

// 카카오맵/Mapbox/퀘스트 화면에서 "대중교통" 버튼을 눌렀을 때 공통으로 쓰는 로직.
// AI 비서용 다국어 프롬프트 구성과 TAGO 실시간 버스 정보 시트 표시를 한 곳에서 관리해
// 세 화면에 동일 로직이 중복되는 것을 방지한다.
String buildTransitPrompt(String targetDisplayName, String currentLang) {
  if (currentLang == 'ko') {
    return '$targetDisplayName(으)로 대중교통(버스, 열차 등)을 이용하여 가는 방법과 최적 경로를 알려줘.';
  } else if (currentLang == 'ja') {
    return '$targetDisplayNameへ公共交通機関（バス、電車など）を利用して行く方法と最適なルートを教えてください。';
  } else if (currentLang == 'zh-chs' || currentLang == 'zh') {
    return '请告诉我如何乘坐公共交通（公交车、火车等）去$targetDisplayName，并提供最佳路线。';
  }
  return 'Please show me how to get to $targetDisplayName using public transit (bus, train, etc.) and give me the best route.';
}

void openTransitInfoSheet(
  BuildContext context, {
  required String targetDisplayName,
  required double lat,
  required double lng,
  required String currentLang,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BusArrivalSheet(
      spotName: targetDisplayName,
      lat: lat,
      lng: lng,
      currentLang: currentLang,
      aiPrompt: buildTransitPrompt(targetDisplayName, currentLang),
    ),
  );
}
