import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/odii_service.dart';
import 'language_select_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Base animation duration
    );

    // Start progress animation
    _progressController.forward();
    
    // Start prefetching data
    _prefetchData();
  }

  Future<void> _prefetchData() async {
    try {
      // Fetch default 'ko' data
      final spots = await OdiiService.fetchGyeongjuSpots('ko');
      if (mounted) {
        context.read<AppState>().setSpotsData(spots);
      }
    } catch (e) {
      print("Error prefetching spots: $e");
    } finally {
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
        _checkAndNavigate();
      }
    }
  }

  void _checkAndNavigate() {
    // If progress animation is done and data is loaded, navigate
    if (_progressController.isCompleted && _dataLoaded) {
      _navigateToNext();
    } else {
      // If data is loaded but animation isn't done, wait for animation
      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed && _dataLoaded && mounted) {
          _navigateToNext();
        }
      });
    }
  }

  void _navigateToNext() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LanguageSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/landing_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0, left: 40, right: 40),
              child: Column(
                children: [
                  const Text(
                    '경주 여행을 준비하는 중입니다...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
