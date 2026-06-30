import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';

import 'screens/landing_screen.dart';
import 'providers/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print("Flutter Binding Initialized");

  // 앱 화면을 먼저 렌더링하도록 runApp을 즉시 실행
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const GyeongjuGoApp(),
    ),
  );

  // 이후 백그라운드에서 환경변수 및 카카오맵 초기화 진행
  _initializeResources();
}

Future<void> _initializeResources() async {
  try {
    await dotenv.load(fileName: ".env");
    print("Dotenv loaded");
    
    AuthRepository.initialize(
      appKey: '8ae79b4318ce3ff35ce6e3f09698b3b0', 
      baseUrl: 'https://localhost',
    );
    print("Kakao Auth initialized");
  } catch (e, stacktrace) {
    print("Initialization Error: $e");
    print(stacktrace);
  }
}

class GyeongjuGoApp extends StatelessWidget {
  const GyeongjuGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyeongju GO',
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
      home: const LandingScreen(),
    );
  }
}
