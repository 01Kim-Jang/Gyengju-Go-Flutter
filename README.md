# 🗺️ Gyeongju-GO (경주-GO)

경주를 찾는 외국인 관광객을 위한 게이미피케이션 여행 플래너 및 스마트 도슨트 앱 **Gyeongju-GO**의 프론트엔드 레포지토리입니다. 

---

## 🎨 주요 특징 (Key Features)

### 1. 🗺️ 듀얼 맵 시스템 & 실시간 번역 오버레이
- **Mapbox 3D 역사 테마 맵**: 역사 소설이나 사극풍 분위기의 3D 지형지도를 제공하며, 실시간 시간대 기반 또는 설정 기준에 따라 주간(Standard) / 야간(Dark) 스타일로 자동 전환됩니다.
- **Kakao 2D 정밀 맵**: 외국인 전용 관광공사 Odii API 명소 데이터를 정밀 2D 지도에 연동하여 사용자 중심의 길찾기를 지원합니다.
- **다국어 오버레이 (CustomOverlay)**: 카카오 지도 타일 한글 문제를 보완하기 위해 마커 위에 선택 언어로 실시간 번역된 **이름 말풍선(CustomOverlay)**을 동적으로 렌더링합니다.

### 2. 🤖 AI 가이드 스마트 비서 & 3종 내비게이션 연동
- **GPT-4o-mini 기반 AI 여행 비서**: 사용자의 현재 GPS 위치 정보를 컨텍스트로 받아 주변 맛집, 카페, 교통편, 역사적 정보에 최적화된 맞춤형 추천을 제공합니다.
- **다국어 길찾기 링크**: AI 비서가 장소를 추천하면 메시지 하단에 **길찾기 카드**가 자동 파싱되어 노출됩니다.
- **3개 이동수단 지원**: **자동차(Drive), 도보(Walk), 대중교통(Transit)** 버튼을 탭하면 사용자의 실시간 GPS 위치와 목적지의 위경도 좌표가 매핑된 카카오맵 외부 웹 길찾기 서비스로 다국어가 반영되어 바로 연결됩니다 (`url_launcher` 연동).

### 3. 🎟️ 포켓스탑 팝업 카드 & 전역 스탬프 북 시스템
- **하프 카드(Half-Sheet) UI**: 마커 터치 시 부드럽게 팝업되는 카드에 다국어 명소명, 고화질 랜드마크 미디어, 스탬프 잠금 상태를 직관적으로 표현합니다.
- **스마트 오디오 도슨트**: '도슨트 재생'을 누르면 다국어 음성 안내(TTS)가 자동으로 재생됩니다. (베트남어, 태국어 등 일부 언어 부재 시 영어 우선 폴백 적용).
- **테마 퀘스트 연동**: 명소에 맞춰 어울리는 테마별 여정(예: 절 ➔ 천년의 사찰 순례) 퀘스트를 즉시 실행할 수 있는 단축 단추를 지원합니다.
- **골드 스탬프 북**: 지도상 명소를 터치 및 스핀(Spin)하면 경험치(+50 XP)를 획득하고, 획득한 골드 스탬프북 대시보드를 통해 6대 랜드마크 방문 상태를 아름답게 시각화합니다.

### 4. 🧭 테마별 여행 플래너 퀘스트 시스템
- 신라 왕릉 탐방, 천년의 사찰 순례, 역사 유적지 산책, 예술과 문화, 자연과 휴식, 황리단길 핫플 탐험 등 6대 테마의 퀘스트 리스트를 지원합니다.
- 퀘스트 시작 시 사용자의 실시간 좌표에서 가장 가까운 목적지를 계산해주고 도보/교통 거리를 시각화합니다.

### 5. ⚙️ 프리미엄 환경설정 (Settings)
전통 한지 배경 디자인의 커스텀 UI를 적용했습니다.
- **위치 서비스 권한**: 실시간 기기 GPS 권한 조회 및 앱 위치 권한 변경 페이지 즉시 이동.
- **오디오 도슨트 토글**: TTS 가이드 음성을 전역으로 켜고 끕니다.
- **지도 화면 테마**: 자동(06시~18시 주간, 18시~다음날 06시 야간 자동 적용) / 낮 모드 고정 / 밤 모드 고정을 지원합니다.
- **캐릭터 스타일 스위처**: 
  - 8등신 신라 전통 일러스트 6종(왕, 왕비, 화랑, 공주, 상인, 현대 여행자)
  - 2등신 귀여운 chibi 픽셀 캐릭터 4종(왕, 왕비, 공주, 화랑)
  - 두 가지 그래픽 모드와 캐릭터 구성을 실시간으로 커스텀 변경하여 모험을 떠날 수 있습니다.
- **서비스 언어 변경**: 한국어, 영어, 일본어, 중국어(간체), 베트남어, 태국어 간의 실시간 전체 UI 다국어 번역 교체.
- **데이터 초기화**: 획득한 스탬프 기록 및 점수를 모두 초기화하고 여정을 다시 시작하는 기능 지원.

### 6. ⚡ 로딩 최적화 & 3D 포켓스탑 동전 스핀 (Performance & High Fidelity)
- **포켓스탑 로딩 속도 즉시 단축 (Preloaded Spots)**: 기존 공공데이터 API 전체 호출 방식의 네트워크 지연 및 파싱 병목을 해결하기 위해 경주 전용 다국어 데이터를 미리 정제하여 패키징([preloaded_spots.dart](file:///c:/Users/baram/.gemini/antigravity/scratch/gyeongju_go_flutter/lib/data/preloaded_spots.dart))하여 첫 앱 실행 및 언어 전환 로딩 속도를 즉각적으로 끌어올렸습니다.
- **3D 동전 스핀 애니메이션 (3D Coin Spin)**: 포켓스탑 원판 터치 및 스와이프 시 3D 원근 투영 행렬(`Matrix4` 및 `rotateY`)을 적용하여 실제 포켓몬 고와 유사한 고품질의 3D 동전 스핀 효과를 완성했습니다.
- **전역 다국어 품질 개선 및 버그 수정**: 카카오맵 버튼 번역 오타(`カカオマップ`) 및 신라 왕릉 퀘스트 오타(`新羅の王陵巡り`)를 바로잡았으며, 퀘스트 화면 내 하드코딩된 한국어 문구와 퀘스트 매칭(키워드 검색) 연산을 다국어 최적화했습니다.

---

## 🛠️ 기술 스택 (Tech Stack)

- **Framework**: Flutter 3.22+ / Dart
- **State Management**: Provider (전역 AppState 언어 및 게임 데이터 싱크)
- **Maps API**: Mapbox Maps Flutter (3D), Kakao Map SDK (2D & CustomOverlay)
- **AI Service**: OpenAI API (GPT-4o-mini 연동 및 다국어 식당 번역)
- **TTS**: Flutter TTS
- **GPS & Location**: Geolocator (실시간 좌표 및 거리 측정)
- **Routing & Launcher**: url_launcher (카카오맵 외부 내비게이션 연결)

---

## 📂 프로젝트 구조 (Directory Structure)

```text
lib/
├── components/
│   └── chatbot_sheet.dart    # AI 스마트 비서 (채팅창 & 내비게이션 연동)
├── data/
│   ├── preloaded_spots.dart  # 성능 최적화를 위한 경주 spots 로컬 프리로드 DB
│   └── spots_db.dart         # 경주 6대 명소 다국어 백과사전 & 미디어 DB
├── models/
│   └── quest.dart            # 플래너 및 일반 퀘스트 데이터 모델
├── providers/
│   └── app_state.dart        # 전역 상태 (오디오, 테마 모드, 캐릭터, 스탬프 등) 관리
├── screens/
│   ├── home_screen.dart      # 탭 기반 메인 네비게이션 화면
│   ├── kakao_map_view.dart   # 카카오맵 뷰 (다국어 CustomOverlay 연동)
│   ├── landing_screen.dart   # 인트로 스플래시 화면
│   ├── language_select_screen.dart # 최초 다국어 선택 화면
│   ├── character_select_screen.dart # 최초 캐릭터 선택 화면
│   ├── mapbox_view.dart      # Mapbox 3D 역사 테마 지도 뷰
│   ├── quest_screen.dart     # 여정 기록, 스탬프 북 및 6대 테마 퀘스트 화면
│   └── settings_screen.dart  # 환경설정 화면 (한지 테마, 자산 관리, 초기화)
├── services/
│   ├── odii_service.dart     # 한국관광공사 Odii API 통신 연동
│   └── openai_service.dart   # OpenAI API 통신 (식당 번역, AI 대화)
└── utils/
    ├── marker_generator.dart # 다국어 오버레이 및 마커 드로잉 유틸
    ├── mock_geolocator.dart  # 테스트용 Mock GPS 스트림
    └── translations.dart     # 6개 국어 리소스 다국어 매트릭스
```

---

## 🚀 시작하기 (Getting Started)

### 1. 환경 설정 (.env)
루트 폴더에 `.env` 파일을 만들고 키를 작성하세요.
```env
OPENAI_API_KEY=YOUR_OPENAI_API_KEY
MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

### 2. 패키지 다운로드 & 실행
```bash
# 의존성 패키지 설치
flutter pub get

# 앱 실행
flutter run
```
