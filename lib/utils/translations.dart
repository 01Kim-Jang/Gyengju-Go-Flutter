class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'ko': {
      'quest': '퀘스트',
      'map': '지도',
      'settings': '설정',
      'quest_dev': '퀘스트 화면 (개발 중)',
      'settings_dev': '설정 화면 (개발 중)',
      'kakao_map_view': '카카오맵 보기',
      'mapbox_view': '3D 사극풍 맵',
      'ai_assistant': '경주 AI 비서',
      'ai_guide_title': 'AI 스마트 비서 (경주 가이드)',
      'ai_guide_hint': '경주에 대해 무엇이든 물어보세요...',
    },
    'en': {
      'quest': 'Quest',
      'map': 'Map',
      'settings': 'Settings',
      'quest_dev': 'Quest Screen (In Dev)',
      'settings_dev': 'Settings Screen (In Dev)',
      'kakao_map_view': 'Kakao Map',
      'mapbox_view': '3D Historical Map',
      'ai_assistant': 'AI Assistant',
      'ai_guide_title': 'AI Smart Assistant (Gyeongju Guide)',
      'ai_guide_hint': 'Ask anything about Gyeongju...',
    },
    'ja': {
      'quest': 'クエスト',
      'map': '地図',
      'settings': '設定',
      'quest_dev': 'クエスト画面 (開発中)',
      'settings_dev': '設定画面 (開発中)',
      'kakao_map_view': 'カカオマップ',
      'mapbox_view': '3D 時代劇マップ',
      'ai_assistant': 'AI アシスタント',
      'ai_guide_title': 'AI スマートアシスタント (慶州ガイド)',
      'ai_guide_hint': '慶州について何でも聞いてください...',
    },
    'zh-chs': {
      'quest': '任务',
      'map': '地图',
      'settings': '设置',
      'quest_dev': '任务画面 (开发中)',
      'settings_dev': '设置画面 (开发中)',
      'kakao_map_view': 'Kakao 地图',
      'mapbox_view': '3D 历史地图',
      'ai_assistant': 'AI 助手',
      'ai_guide_title': 'AI 智能助手 (庆州指南)',
      'ai_guide_hint': '询问关于庆州的任何问题...',
    },
    'vi': {
      'quest': 'Nhiệm vụ',
      'map': 'Bản đồ',
      'settings': 'Cài đặt',
      'quest_dev': 'Màn hình nhiệm vụ(Đang pt)',
      'settings_dev': 'Màn hình cài đặt (Đang pt)',
      'kakao_map_view': 'Bản đồ Kakao',
      'mapbox_view': 'Bản đồ lịch sử 3D',
      'ai_assistant': 'Trợ lý AI',
      'ai_guide_title': 'Trợ lý thông minh AI (Hướng dẫn Gyeongju)',
      'ai_guide_hint': 'Hỏi bất cứ điều gì về Gyeongju...',
    },
    'th': {
      'quest': 'ภารกิจ',
      'map': 'แผนที่',
      'settings': 'การตั้งค่า',
      'quest_dev': 'หน้าจอภารกิจ (กำลังพัฒนา)',
      'settings_dev': 'หน้าจอการตั้งค่า (กำลังพัฒนา)',
      'kakao_map_view': 'แผนที่ Kakao',
      'mapbox_view': 'แผนที่ประวัติศาสตร์ 3D',
      'ai_assistant': 'ผู้ช่วย AI',
      'ai_guide_title': 'ผู้ช่วยอัจฉริยะ AI (คู่มือคยองจู)',
      'ai_guide_hint': 'ถามอะไรเกี่ยวกับคยองจูได้เลย...',
    },
  };

  static String get(String langCode, String key) {
    if (translations.containsKey(langCode) && translations[langCode]!.containsKey(key)) {
      return translations[langCode]![key]!;
    }
    // Fallback to Korean
    return translations['ko']![key] ?? key;
  }
}
