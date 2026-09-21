import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'providers/app_state.dart';
import 'services/user_service.dart';
import 'services/notification_service.dart';
import 'widgets/mobile_web_frame.dart';
import 'widgets/announcement_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Flutter Binding Initialized");

  // 웹은 .env를 네트워크로 fetch하므로, 지도 화면(Mapbox 토큰 필요)에 먼저
  // 도달해버리는 race를 막기 위해 runApp 전에 반드시 로드를 끝낸다.
  // 파일명은 dotfile(.env)이 아닌 env.config를 쓴다 — Flutter 웹 빌드가 에셋
  // 매니페스트를 만들 때 숨김파일(.으로 시작)을 통째로 빼버려서, 서버에 실제
  // 파일이 있어도 rootBundle이 못 찾아 항상 빈 값으로 로드되는 문제가 있었다.
  await dotenv.load(fileName: "env.config");
  debugPrint("Dotenv loaded");

  // 지도 위젯이 빌드될 때마다 토큰을 다시 세팅하는 대신, 웹에서 Mapbox GL JS
  // 레이어가 초기화되기 전에 최대한 일찍 한 번만 세팅해서 race를 줄인다.
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const GyeongjuGoApp(),
    ),
  );

  // 이후 백그라운드에서 나머지(카카오/Firebase/알림) 초기화 진행
  _initializeResources();
}

Future<void> _initializeResources() async {
  try {
    AuthRepository.initialize(
      appKey: '8ae79b4318ce3ff35ce6e3f09698b3b0',
      baseUrl: 'https://localhost',
    );
    debugPrint("Kakao Auth initialized");

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await UserService.ensureSignedIn();
    debugPrint("Firebase initialized & signed in (uid: ${UserService.uid})");

    await NotificationService.init();
    debugPrint("Notifications initialized");
  } catch (e, stacktrace) {
    debugPrint("Initialization Error: $e");
    debugPrint(stacktrace.toString());
  }
}

class GyeongjuGoApp extends StatefulWidget {
  const GyeongjuGoApp({super.key});

  @override
  State<GyeongjuGoApp> createState() => _GyeongjuGoAppState();
}

class _GyeongjuGoAppState extends State<GyeongjuGoApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // 랜딩 스플래시 전환(약 2초) 이후, 어느 화면에 있든 공지를 한 번 띄운다.
    // navigatorKey를 쓰면 특정 화면의 BuildContext/라우트 전환에 얽매이지 않는다.
    Future.delayed(const Duration(milliseconds: 2500), () {
      final overlayContext = _navigatorKey.currentState?.overlay?.context;
      if (overlayContext != null && mounted) {
        showAnnouncementDialog(overlayContext);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Gyeongju GO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Gold/Brown theme
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      builder: (context, child) => MobileWebFrame(child: child ?? const SizedBox.shrink()),
      home: const LandingScreen(),
    );
  }
}
