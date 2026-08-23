# 🗺️ Gyeongju-GO (경주-GO)

경주를 찾는 외국인 관광객을 위한 게이미피케이션 여행 플래너 및 스마트 도슨트 앱 **Gyeongju-GO**의 프론트엔드 레포지토리입니다. 

---

## 🎨 주요 특징 (Key Features)

### 1. 🗺️ 듀얼 맵 시스템 & 실시간 번역 오버레이
- **게임모드(Mapbox) 기본 진입**: 앱을 처음 켜면 포켓스탑·스탬프·캐릭터 등 게이미피케이션 경험이 담긴 게임모드로 바로 진입합니다. 지도 화면에서 중앙 지도 버튼을 누르면 카카오맵/게임모드 전환 시트가 열립니다.
- **Mapbox 3D 역사 테마 맵**: 역사 소설이나 사극풍 분위기의 3D 지형지도를 제공하며, 실시간 시간대 기반 또는 설정 기준에 따라 주간(Standard) / 야간(Dark) 스타일로 자동 전환됩니다.
- **Kakao 2D 정밀 맵**: 외국인 전용 관광공사 Odii API 명소 데이터를 정밀 2D 지도에 연동하여 사용자 중심의 길찾기를 지원합니다.
- **실시간 내 위치 추적**: Kakao 맵에서도 실시간 GPS 위치를 펄스 도트로 표시하고, 우측 하단 버튼 한 번으로 현재 위치로 즉시 이동할 수 있습니다.
- **다국어 오버레이 (CustomOverlay)**: 카카오 지도 타일 한글 문제를 보완하기 위해 마커 위에 선택 언어로 실시간 번역된 **이름 말풍선(CustomOverlay)**을 동적으로 렌더링합니다.

### 2. 🤖 AI 가이드 스마트 비서 & 3종 내비게이션 연동
- **GPT-4o-mini 기반 AI 여행 비서**: 사용자의 현재 GPS 위치 정보를 컨텍스트로 받아 주변 맛집, 카페, 교통편, 역사적 정보에 최적화된 맞춤형 추천을 제공합니다.
- **다국어 길찾기 링크**: AI 비서가 장소를 추천하면 메시지 하단에 **길찾기 카드**가 자동 파싱되어 노출됩니다.
- **3개 이동수단 지원**: **자동차(Drive), 도보(Walk), 대중교통(Transit)** 버튼을 탭하면 사용자의 실시간 GPS 위치와 목적지의 위경도 좌표가 매핑된 카카오맵 외부 웹 길찾기 서비스로 다국어가 반영되어 바로 연결됩니다 (`url_launcher` 연동).
- **실시간 도보 내비게이션**: '도보' 선택 시 Mapbox Directions API로 계산한 경로가 골드/노란색 라인으로 지도에 표시되고, 걷는 동안 위치가 바뀌면(20m 이상 이동 시) 자동으로 경로를 다시 계산해 실제로 따라오는 것처럼 트래킹됩니다. 목적지 25m 이내 도착 시 경로가 자동으로 종료됩니다.
- **TAGO 실시간 버스 도착정보 & 정류소 접근 알림**: 대중교통 버튼을 탭하면 국토교통부(TAGO) OpenAPI로 목적지 주변 가장 가까운 버스정류소와 노선별 실시간 도착 예정 시간(분 단위)·잔여 정류장 수를 바로 보여줍니다. 정류소에 도착 예정 버스가 없으면 가까운 순으로 다음 정류소를 자동 재탐색하며, 필요 시 AI 비서에게 경로를 추가로 물어볼 수 있는 버튼도 함께 제공합니다. 이후 실제로 정류소(40m 이내)에 가까워지면 어떤 버스를 타야 하는지 알림 시트가 자동으로 한 번 떠서, 정류장을 지나칠 때마다 반복적으로 뜨지 않고 필요할 때만 안내합니다.

### 3. 🎟️ 포켓스탑 팝업 카드 & 전역 스탬프 북 시스템
- **하프 카드(Half-Sheet) UI**: 마커 터치 시 부드럽게 팝업되는 카드에 다국어 명소명, 고화질 랜드마크 미디어, 스탬프 잠금 상태를 직관적으로 표현합니다.
- **스마트 오디오 도슨트**: '도슨트 재생'을 누르면 다국어 음성 안내(TTS)가 자동으로 재생됩니다. (베트남어, 태국어 등 일부 언어 부재 시 영어 우선 폴백 적용). 재생 중에는 같은 버튼이 '정지' 버튼으로 바뀌어 즉시 중지할 수 있습니다.
- **테마 퀘스트 연동**: 명소에 맞춰 어울리는 테마별 여정(예: 절 ➔ 천년의 사찰 순례) 퀘스트를 즉시 실행할 수 있는 단축 단추를 지원합니다.
- **골드 스탬프 북**: 지도상 명소를 터치 및 스핀(Spin)하면 경험치(+50 XP)를 획득하고, 획득한 골드 스탬프북 대시보드를 통해 6대 랜드마크 방문 상태를 아름답게 시각화합니다.

### 4-1. 👥 소셜 (친구 & 실시간 파티, Firebase 동기화)
- **익명 인증 & 친구 코드**: 앱 최초 실행 시 Firebase 익명 인증으로 자동 로그인되며, 기기별 고유 6자리 친구 코드가 발급됩니다.
- **친구 추가**: 친구 코드를 직접 입력하거나, 상대방의 QR 코드를 스캔해 즉시 친구로 등록할 수 있습니다. 친구 목록에서 각 친구의 캐릭터·닉네임·수집한 스탬프 수를 확인할 수 있습니다.
- **실시간 파티(함께하기)**: 파티 생성 시 실제로 유일한 8자리 초대 코드가 Firestore에 발급되며, 코드 입력 또는 QR 스캔으로 참가하면 모든 파티원의 목록·위치·진행률이 실시간으로 동기화됩니다. 방장이 나가면 다음 파티원에게 자동으로 방장이 위임됩니다.
- **통합 화면 레이아웃**: 파티와 친구 기능을 하나의 "소셜" 탭으로 통합. 좌상단 아이콘으로 친구 목록, 우상단 아이콘으로 친구 추가(자동으로 추가 다이얼로그 오픈)에 바로 접근합니다.
- **친구 위치 공유 (여성안심/자녀안심)**: 설정에서 전역 토글을 켜면 게임모드 지도에 친구들의 캐릭터와 이름표가 실시간으로 표시됩니다. 기본값은 OFF이며 앱이 켜져 있을 때만 위치가 갱신됩니다. 위치 데이터는 `users/{uid}`와 분리된 `locations/{uid}` 컬렉션에 저장되고, firestore.rules에서 본인 또는 실제 친구 관계(friendships 문서 존재)일 때만 읽을 수 있도록 제한해 친구가 아닌 사용자에게는 노출되지 않습니다.

### 4-2. 🧭 AI 동선 최적화 여행 플래너 퀘스트 시스템
- 신라 왕릉 탐방, 천년의 사찰 순례, 역사 유적지 산책, 예술과 문화, 자연과 휴식, 황리단길 핫플 탐험 등 6대 테마의 퀘스트 리스트를 지원합니다.
- **AI 동선 최적화**: 퀘스트 시작 시 현재 위치를 출발점으로 남은 목적지들을 총 이동거리가 최소가 되는 순서로 계산합니다(지점이 적어 완전탐색 방식으로 실제 최적해를 구함).
- **순차 체크리스트**: 진행 중인 퀘스트 카드를 탭하면 계산된 방문 순서가 목록으로 나열되고, 각 장소를 방문할 때마다 왼쪽에 체크 표시가 실시간으로 반영됩니다.
- **문화 예절 팁**: 사찰·왕릉·유적지·박물관 테마 퀘스트 카드에 방문 예절(신발 벗기, 봉분 출입 금지, 문화재 비접촉, 플래시 자제 등)을 짧게 안내합니다.

### 4-2-1. 📖 여행 보고서 (일지/회고)
- 퀘스트 화면에서 "여행 보고서" 버튼으로 진입하며, 앱이 켜져 있는 동안(30m 이상 이동 시) 로컬에 기록해둔 GPS 궤적을 지도 위에 실제 걸은 경로처럼 다시 그려줍니다. 방문한 포켓스탑은 방문 순서·시각과 함께 지도 위 이름표 및 하단 리스트로 표시됩니다.
- **하루 단위 / 전체 여행 통합 보기**: 상단 칩으로 날짜별 기록 또는 전체 여행 기간을 합친 통합 경로 중 원하는 걸 선택해서 볼 수 있습니다.
- **로컬 저장**: `shared_preferences` 기반으로 기기에 직접 저장되어 Firebase 연동 여부와 무관하게 오프라인에서도 동작합니다. (참고: 이 기능을 위해 앱에 처음으로 로컬 저장 계층을 도입했습니다 — 이전에는 점수·스탬프 등 모든 진행 상황이 앱 재시작 시 초기화됐습니다.)
- 앱이 완전히 종료된 구간은 궤적이 기록되지 않아 그 구간만 직선으로 이어지는 한계가 있습니다 (구글 타임라인처럼 OS 상시 백그라운드 추적은 사용하지 않음).

### 4-3. 🚨 긴급/안전 정보
- 하단 네비게이션의 독립 탭으로 어디서든 한 번에 진입: 112(경찰)/119(소방·구급)/1330(한국관광공사 24시간 다국어 관광통역 안내) 원터치 전화 연결
- 현재 위치 기준 근처 약국·병원을 카카오 로컬 API로 검색
- 자국 대사관 연락처를 모를 때 1330 연결 안내 및 외교부 공식 홈페이지 링크 제공

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

### 6. ⚡ 로딩 최적화, 3D 동전 스핀 및 사용자 피드백 반영 (Performance & High Fidelity)
- **포켓스탑 로딩 속도 즉시 단축 (Preloaded Spots)**: 기존 공공데이터 API 전체 호출 방식의 네트워크 지연 및 파싱 병목을 해결하기 위해 경주 전용 다국어 데이터를 미리 정제하여 패키징([preloaded_spots.dart](file:///c:/Users/baram/.gemini/antigravity/scratch/gyeongju_go_flutter/lib/data/preloaded_spots.dart))하여 첫 앱 실행 및 언어 전환 로딩 속도를 즉각적으로 끌어올렸습니다.
- **3D 동전 스핀 애니메이션 (3D Coin Spin)**: 포켓스탑 원판 터치 및 스와이프 시 3D 원근 투영 행렬(`Matrix4` 및 `rotateY`)을 적용하여 실제 포켓몬 고와 유사한 고품질의 3D 동전 스핀 효과를 완성했습니다.
- **다국어 좌표 역매핑 이미지 매칭**: 언어 변경 시 포켓스탑 제목이 번역되어 이미지가 나타나지 않던 오류를 해결하기 위해, `mapX`/`mapY` 경위도 좌표값을 이용하여 한국어 원본 이미지 파일 경로를 역적용하도록 로직을 재설계했습니다.
- **지도 무한 회전 제거**: 포켓스탑 진입 시 발생하던 카메라 360도 무한 공전 회전 애니메이션을 멈추고 고정 정적 포커스(FlyTo)로 변경하여 유저의 멀미/어지러움 증상을 해결했습니다.
- **AI 비서 연동형 대중교통 길찾기**: 기존 인앱 웹뷰의 카카오맵 모바일 웹페이지 내 외부 앱 전환 스키마 오류(`ERR_UNKNOWN_URL_SCHEME`)를 해결하기 위해, 대중교통 길찾기 버튼을 탭하면 AI 비서(GPT API) 대화창이 자동 실행되며 해당 목적지까지의 버스/열차 등의 최적 이동 경로 안내 프롬프트를 자동으로 작동하도록 구현했습니다.
- **전역 다국어 품질 개선 및 버그 수정**: 카카오맵 버튼 번역 오타(`カカオマップ` 수정) 및 신라 왕릉 퀘스트 오타(`新羅の王陵巡り` 수정), 교촌마을 오역("서악서원-도리마을"로 나타나던 영/일/중 번역 데이터 오류 수정)을 바로잡았습니다.

---

## 🛠️ 기술 스택 (Tech Stack)

- **Framework**: Flutter 3.22+ / Dart
- **State Management**: Provider (전역 AppState 언어 및 게임 데이터 싱크)
- **Maps API**: Mapbox Maps Flutter (3D), Kakao Map SDK (2D & CustomOverlay)
- **AI Service**: OpenAI API (GPT-4o-mini 연동 및 다국어 식당 번역)
- **Tourism Data**: 한국관광공사 Odii OpenAPI (경주 명소 다국어 데이터)
- **Public Transit**: 국토교통부 TAGO OpenAPI (좌표기반 근접정류소 조회 + 정류소별 실시간 버스 도착정보)
- **Backend**: Firebase Auth (익명 인증), Cloud Firestore (친구/파티 실시간 동기화)
- **QR**: qr_flutter (생성), mobile_scanner (스캔)
- **TTS**: Flutter TTS
- **GPS & Location**: Geolocator (실시간 좌표 및 거리 측정)
- **Routing & Launcher**: url_launcher (카카오맵 외부 내비게이션 연결)
- **Local Storage**: shared_preferences (여행 보고서 GPS 궤적·방문 기록 로컬 저장)

---

## 📂 프로젝트 구조 (Directory Structure)

```text
lib/
├── components/
│   ├── chatbot_sheet.dart    # AI 스마트 비서 (채팅창 & 내비게이션 연동)
│   └── docent_sheet.dart     # 오디오 도슨트 요약/재생 시트
├── data/
│   ├── preloaded_spots.dart  # 성능 최적화를 위한 경주 spots 로컬 프리로드 DB
│   └── spots_db.dart         # 경주 명소 다국어 백과사전 & 미디어 DB
├── firebase_options.dart     # `flutterfire configure`로 자동 생성되는 Firebase 프로젝트 설정
├── models/
│   ├── friend_profile.dart   # 친구 프로필 데이터 모델
│   ├── party.dart            # 소셜 파티(함께하기) 데이터 모델
│   └── quest.dart            # 플래너 및 일반 퀘스트 데이터 모델
├── providers/
│   └── app_state.dart        # 전역 상태 (오디오, 테마 모드, 캐릭터, 스탬프, 파티 등) 관리
├── screens/
│   ├── character_select_screen.dart # 최초 캐릭터 선택 화면
│   ├── friends_screen.dart   # 친구 목록 · 추가(코드/QR) 화면
│   ├── home_screen.dart      # 탭 기반 메인 네비게이션 화면
│   ├── kakao_map_view.dart   # 카카오맵 뷰 (다국어 CustomOverlay 연동)
│   ├── landing_screen.dart   # 인트로 스플래시 화면
│   ├── language_select_screen.dart # 최초 다국어 선택 화면
│   ├── mapbox_view.dart      # Mapbox 3D 역사 테마 지도 뷰
│   ├── party_screen.dart     # 소셜 파티(함께하기) 생성/참가 화면
│   ├── qr_scan_screen.dart   # 친구/파티 공용 QR 스캐너
│   ├── quest_screen.dart     # 여정 기록, 스탬프 북 및 테마 퀘스트 화면
│   ├── safety_info_screen.dart # 긴급/안전 정보 (112/119/1330, 근처 약국·병원, 대사관)
│   ├── settings_screen.dart  # 환경설정 화면 (한지 테마, 자산 관리, 초기화)
│   └── trip_report_screen.dart # 여행 보고서 (일지/회고) - 하루 단위/전체 여행 GPS 궤적 지도 재생
├── services/
│   ├── friend_service.dart   # 친구 추가/목록 실시간 스트림 (Firestore)
│   ├── kakao_local_service.dart # 카카오 로컬 API (주변 맛집 검색) 연동
│   ├── odii_service.dart     # 한국관광공사 Odii API 통신 연동
│   ├── openai_service.dart   # OpenAI API 통신 (식당 번역, AI 대화)
│   ├── party_service.dart    # 파티 생성/참가/실시간 동기화 (Firestore)
│   ├── tago_service.dart     # 국토교통부 TAGO API (근접정류소 · 실시간 버스 도착정보)
│   ├── trip_log_service.dart # 여행 보고서용 GPS 궤적/방문 기록 로컬 저장 (shared_preferences)
│   └── user_service.dart     # 익명 인증 & 사용자 프로필/친구코드 (Firebase)
├── utils/
│   ├── marker_generator.dart # 다국어 오버레이 및 마커 드로잉 유틸
│   ├── mock_geolocator.dart  # 테스트용 Mock GPS 스트림
│   ├── transit_helper.dart   # 대중교통 버튼 공통 로직(AI 프롬프트 + TAGO 시트 표시)
│   └── translations.dart     # 6개 국어 리소스 다국어 매트릭스
└── widgets/
    ├── bus_arrival_sheet.dart    # TAGO 실시간 버스 도착정보 바텀시트
    ├── in_app_route_webview.dart # 인앱 길찾기 웹뷰
    ├── pokestop_modal.dart       # 포켓스탑 팝업 카드 (스핀, 스탬프, 도슨트 진입점)
    ├── qr_code_display_sheet.dart # 친구코드/파티초대코드 QR 표시 바텀시트
    └── quest_route_sheet.dart    # AI 최적 동선 순차 체크리스트 바텀시트
```

---

## 🚀 시작하기 (Getting Started)

### 1. 환경 설정 (.env)
루트 폴더에 `.env` 파일을 만들고 키를 작성하세요.
```env
OPENAI_API_KEY=YOUR_OPENAI_API_KEY
MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
KAKAO_REST_API_KEY=YOUR_KAKAO_REST_API_KEY
ODII_SERVICE_KEY=YOUR_ODII_SERVICE_KEY
TAGO_SERVICE_KEY=YOUR_TAGO_SERVICE_KEY
```

### 2. Firebase 설정 (친구 & 파티 기능에 필요)
친구/파티 기능은 Firebase Auth(익명 인증) + Cloud Firestore를 사용합니다.

1. [Firebase 콘솔](https://console.firebase.google.com)에서 프로젝트를 생성합니다.
2. **Firestore Database**를 만듭니다 (위치: `asia-northeast3` 권장, 테스트 모드로 시작 가능).
3. **Authentication → 로그인 방법**에서 "익명"을 활성화합니다.
4. 아래 CLI로 이 프로젝트를 Firebase와 연동합니다.
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure   # 플랫폼은 android, web 선택
   ```
   완료되면 `lib/firebase_options.dart`가 실제 프로젝트 값으로 자동 생성/교체됩니다.
5. Firestore 보안 규칙을 배포합니다.
   ```bash
   firebase deploy --only firestore:rules
   ```
   (또는 Firebase 콘솔 → Firestore → 규칙 탭에 `firestore.rules` 내용을 그대로 붙여넣어도 됩니다.)

> `flutterfire configure`를 아직 실행하지 않았다면 친구/파티 탭 진입 시 오류가 표시될 수 있지만, 그 외 지도·퀘스트·도슨트 등 나머지 기능은 정상 동작합니다.

### 3. 패키지 다운로드 & 실행
```bash
# 의존성 패키지 설치
flutter pub get

# 앱 실행
flutter run
```
