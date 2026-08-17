import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/openai_service.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';

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
    final originalTitle = widget.spotData['title'] ?? AppTranslations.get(lang, 'unknown_place');

    // 어떤 이유로든(네트워크 예외, dotenv 미초기화 등) 실패하더라도 로딩 스피너가
    // 영원히 멈추지 않는 사고를 막기 위해 전체를 try/finally로 감싼다.
    try {
      // Odii 데이터에 overview가 없을 수 있으므로 AI로 생성
      String originalText = widget.spotData['overview'] ?? '';
      if (originalText.isEmpty) {
        originalText = await OpenAIService.generateDocentScript(originalTitle);
      }

      if (lang == 'ko') {
        translatedSummary = originalText;
        translatedTitle = originalTitle;
      } else {
        // 제목과 내용 번역
        translatedTitle = await OpenAIService.translateText(originalTitle, lang);
        translatedSummary = await OpenAIService.translateText(originalText, lang);
      }
    } catch (e) {
      debugPrint('DocentSheet load error: $e');
      translatedTitle ??= originalTitle;
      translatedSummary ??= AppTranslations.get(lang, 'docent_load_error');
    } finally {
      if (mounted) {
        setState(() {
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
    final currentLang = context.watch<AppState>().currentLanguage;
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
                  translatedTitle ?? widget.spotData['title'] ?? AppTranslations.get(currentLang, 'unknown_place'),
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
          Text(
            AppTranslations.get(currentLang, 'docent_summary'),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
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
