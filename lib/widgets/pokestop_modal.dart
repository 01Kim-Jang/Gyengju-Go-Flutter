import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';

class PokestopModal extends StatefulWidget {
  final Map<String, dynamic> spotData;

  const PokestopModal({super.key, required this.spotData});

  @override
  State<PokestopModal> createState() => _PokestopModalState();
}

class _PokestopModalState extends State<PokestopModal>
    with SingleTickerProviderStateMixin {
  late FlutterTts flutterTts;
  double _rotation = 0.0;
  bool _isSpun = false;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _spinController.addListener(() {
      setState(() {
        _rotation = _spinController.value * 10 * math.pi; // Spin multiple times
      });
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpun = true;
        });
        _playDocent();
      }
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _playDocent() async {
    final title = widget.spotData['title'] ?? '유적지';
    final desc = widget.spotData['overview'] ?? '$title에 오신 것을 환영합니다.';
    await flutterTts.speak(desc);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _spinController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSpun && !_spinController.isAnimating) {
      setState(() {
        _rotation += details.delta.dx * 0.05;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isSpun && !_spinController.isAnimating) {
      // If swept fast enough, trigger the spin animation
      if (details.velocity.pixelsPerSecond.dx.abs() > 500) {
        _spinController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.spotData['title'] ?? '포켓스탑';
    final imageUrl = widget.spotData['firstimage'] ?? '';
    final localAssetPath =
        'assets/images/spots/${title.replaceAll(' ', '_').replaceAll('/', '_')}.jpg';

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('원을 드래그해서 회전시켜보세요!', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.rotate(
                  angle: _rotation,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(localAssetPath),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback
                        },
                      ),
                    ),
                    // If image fails, it will just show the blue border circle with white bg
                    child: ClipOval(
                      child: Image.asset(
                        localAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          if (imageUrl.isNotEmpty &&
                              imageUrl.startsWith('http')) {
                            return Image.network(imageUrl, fit: BoxFit.cover);
                          }
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.museum, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isSpun) ...[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$title 도슨트 재생 중...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 80),
          ],
        ],
      ),
    );
  }
}
