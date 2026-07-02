import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/openai_service.dart';
import '../providers/app_state.dart';

class DocentSheet extends StatefulWidget {
  final Map<String, dynamic> spotData;

  const DocentSheet({super.key, required this.spotData});

  @override
  State<DocentSheet> createState() => _DocentSheetState();
}

class _DocentSheetState extends State<DocentSheet> {
  FlutterTts? flutterTts;
  bool isPlaying = false;
  String? translatedSummary;
  String? translatedTitle;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslatedText();
  }

  Future<void> _initTts() async {
    if (flutterTts != null) return;
    flutterTts = FlutterTts();

    // 언어 설정
    final appState = context.read<AppState>();
    final lang = appState.currentLanguage;
    String ttsLang = 'ko-KR';
    if (lang == 'en')
      ttsLang = 'en-US';
    else if (lang == 'ja')
      ttsLang = 'ja-JP';
    else if (lang == 'zh')
      ttsLang = 'zh-CN';
    else if (lang == 'th')
      ttsLang = 'th-TH';

    await flutterTts!.setLanguage(ttsLang);
    await flutterTts!.setSpeechRate(0.5);
    await flutterTts!.setVolume(1.0);
    await flutterTts!.setPitch(1.0);

    flutterTts!.setCompletionHandler(() {
      if (mounted) setState(() => isPlaying = false);
    });
  }

  @override
  void dispose() {
    flutterTts?.stop();
    super.dispose();
  }

  Future<void> _loadTranslatedText() async {
    final appState = context.read<AppState>();
    final lang = appState.currentLanguage;
    final originalTitle = widget.spotData['title'] ?? '알 수 없는 장소';

    // Odii 데이터에 overview가 없을 수 있으므로 AI로 생성
    String originalText = widget.spotData['overview'] ?? '';
    if (originalText.isEmpty) {
      originalText = await OpenAIService.generateDocentScript(originalTitle);
    }

    if (lang == 'ko') {
      if (mounted) {
        setState(() {
          translatedSummary = originalText;
          translatedTitle = originalTitle;
          isLoading = false;
        });
      }
    } else {
      // 제목과 내용 번역
      final tTitle = await OpenAIService.translateText(originalTitle, lang);
      final tSummary = await OpenAIService.translateText(originalText, lang);

      if (mounted) {
        setState(() {
          translatedTitle = tTitle;
          translatedSummary = tSummary;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _speak() async {
    if (translatedSummary == null || translatedSummary!.isEmpty) return;

    if (isPlaying) {
      await flutterTts?.stop();
      setState(() => isPlaying = false);
    } else {
      await _initTts();
      setState(() => isPlaying = true);
      await flutterTts?.speak(translatedSummary!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  translatedTitle ?? widget.spotData['title'] ?? '알 수 없는 장소',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                ),
                color: const Color(0xFFD4AF37),
                iconSize: 48,
                onPressed: isLoading ? null : _speak,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '오디오 도슨트 요약',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      translatedSummary ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
