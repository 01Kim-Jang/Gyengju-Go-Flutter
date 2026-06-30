# Gyeongju-GO Flutter App

경주 외국인 관광객을 위한 게이미피케이션 여행 앱 **Gyeongju-GO**의 프론트엔드 앱입니다.

## 기술 스택

* **Flutter 3.22+ / Dart**
* **상태 관리**: Provider
* **지도 연동**: 
  * Mapbox Maps Flutter (3D 사극풍 맵 및 지형)
  * Kakao Map Plugin (한국형 지도)
* **API 및 네트워킹**: HTTP (`http`)
* **음성 안내 (TTS)**: Flutter TTS
* **기타 주요 패키지**: 
  * `flutter_dotenv` (환경 변수 관리)
  * `geolocator` (GPS 기반 사용자 위치)

## 주요 기능

| 기능 | 설명 |
|---|---|
| **듀얼 맵 시스템** | Mapbox 기반의 3D 입체 지도와 Kakao 기반의 2D 정밀 지도 제공 |
| **다국어 지원** | 한국어, 영어, 일본어, 중국어(간체), 베트남어, 태국어 실시간 변경 |
| **오디오 도슨트** | TTS와 AI(OpenAI)를 결합하여 다국어 명소 자동 해설 낭독 |
| **AI 스마트 비서** | 경주 여행과 관련된 모든 것을 물어볼 수 있는 OpenAI 기반 챗봇 |
| **위치 기반 서비스** | 사용자의 현재 위치를 기반으로 주변 관광 명소(포켓스탑) 탐색 |

## 시작하기

### 사전 요구사항

* Flutter SDK (3.22 이상 권장)
* Android Studio (안드로이드 에뮬레이터 또는 실기기)
* JDK 17

### 환경 설정

프로젝트 루트에 `.env` 파일을 생성하고 아래의 API 키들을 채워주세요.

```env
OPENAI_API_KEY=당신의_OPENAI_API_키
MAPBOX_ACCESS_TOKEN=당신의_MAPBOX_ACCESS_TOKEN
```

### 실행

```bash
# 의존성 패키지 설치
flutter pub get

# 앱 실행 (안드로이드)
flutter run
```

## 지원 언어

우측 하단의 설정 또는 챗봇에서 실시간 언어 변경이 가능합니다.

| 코드 | 언어 |
|---|---|
| `ko` | 한국어 |
| `en` | English |
| `ja` | 日本語 |
| `zh-chs` | 中文 |
| `vi` | Tiếng Việt |
| `th` | ภาษาไทย |

## 프로젝트 구조

```text
lib/
├── components/
│   ├── chatbot_sheet.dart    # AI 스마트 비서 (챗봇) UI
│   └── docent_sheet.dart     # 명소 상세 정보 및 오디오 도슨트 UI
├── providers/
│   └── app_state.dart        # 전역 상태 (언어, 맵 타입 등) 관리
├── screens/
│   ├── home_screen.dart      # 메인 탭 화면 (지도, 퀘스트, 설정 뷰)
│   ├── kakao_map_view.dart   # 카카오맵 연동 뷰
│   ├── landing_screen.dart   # 초기 스플래시/랜딩 화면
│   └── mapbox_view.dart      # Mapbox 3D 뷰 및 포켓스탑 렌더링
├── services/
│   ├── odii_service.dart     # 한국관광공사 Odii API 연동
│   └── openai_service.dart   # ChatGPT 연동 (번역, 도슨트, 챗봇)
└── utils/
    ├── mock_geolocator.dart  # 에뮬레이터 테스트용 가상 GPS
    └── translations.dart     # 다국어 번역 데이터
```
