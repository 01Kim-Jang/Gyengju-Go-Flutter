import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/mock_geolocator.dart';
import '../services/openai_service.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';

class ChatBotSheet extends StatefulWidget {
  const ChatBotSheet({super.key});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<ChatBotSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _controller.clear();

    final appState = context.read<AppState>();
    final targetLang = appState.currentLanguage;

    double? lat = appState.userLat;
    double? lng = appState.userLng;

    final response = await OpenAIService.chatWithAI(
      text,
      targetLang,
      lat: lat,
      lng: lng,
    );

    setState(() {
      _messages.add({'role': 'bot', 'content': response});
      _isLoading = false;
    });
  }

  Future<void> _launchKakaoRoute(double destLat, double destLng, String name, String mode) async {
    final appState = context.read<AppState>();
    // Default to Gyeongju station coordinates if current user location is null
    final startLat = appState.userLat ?? 35.8348;
    final startLng = appState.userLng ?? 129.2266;
    
    // by parameter: 'car' (자동차), 'foot' (도보), 'publictransit' (대중교통)
    final urlString = 'https://map.kakao.com/link/route?sp=$startLat,$startLng&ep=$destLat,$destLng&by=$mode';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // In case launching fails, display snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot launch route: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentLang = appState.currentLanguage;
    final titleStr = AppTranslations.get(currentLang, 'ai_guide_title');

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7), // warm hanji background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.support_agent, color: Color(0xFFD4AF37), size: 28),
                const SizedBox(width: 8),
                Text(
                  titleStr,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Serif'),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFD7CCC8)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final rawContent = msg['content'] ?? '';

                if (isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 40),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        rawContent,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  );
                } else {
                  // Bot message: parse all [ROUTE:Name,Lat,Lng]
                  final RegExp routeRegExp = RegExp(r'\[ROUTE:(.*?),(.*?),(.*?)\]');
                  final Iterable<RegExpMatch> matches = routeRegExp.allMatches(rawContent);
                  
                  // Clean content from route tags
                  final cleanContent = rawContent.replaceAll(routeRegExp, '').trim();

                  List<Widget> routeButtons = [];
                  for (final match in matches) {
                    final name = match.group(1) ?? 'Destination';
                    final latStr = match.group(2) ?? '0.0';
                    final lngStr = match.group(3) ?? '0.0';
                    final destLat = double.tryParse(latStr) ?? 35.8348;
                    final destLng = double.tryParse(lngStr) ?? 129.2266;

                    routeButtons.add(
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.navigation, color: Color(0xFFD4AF37), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3E2723)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Car Mode
                                ElevatedButton.icon(
                                  onPressed: () => _launchKakaoRoute(destLat, destLng, name, 'car'),
                                  icon: const Icon(Icons.directions_car, size: 14),
                                  label: Text(AppTranslations.get(currentLang, 'route_by_car'), style: const TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    backgroundColor: const Color(0xFF8D6E63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                // Walk Mode
                                ElevatedButton.icon(
                                  onPressed: () => _launchKakaoRoute(destLat, destLng, name, 'foot'),
                                  icon: const Icon(Icons.directions_walk, size: 14),
                                  label: Text(AppTranslations.get(currentLang, 'route_by_foot'), style: const TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    backgroundColor: const Color(0xFF8D6E63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                // Transit Mode
                                ElevatedButton.icon(
                                  onPressed: () => _launchKakaoRoute(destLat, destLng, name, 'publictransit'),
                                  icon: const Icon(Icons.directions_bus, size: 14),
                                  label: Text(AppTranslations.get(currentLang, 'route_by_transit'), style: const TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    backgroundColor: const Color(0xFF8D6E63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD7CCC8)),
                            ),
                            child: Text(
                              cleanContent,
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                            ),
                          ),
                          ...routeButtons,
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: AppTranslations.get(
                        currentLang,
                        'ai_guide_hint',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
