import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/quest.dart';
import '../utils/translations.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final quests = appState.quests;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ancient_parchment_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    AppTranslations.get(appState.currentLanguage, 'quest_title'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif', // Classic serif for ancient look
                      color: Color(0xFF3E2723), // Dark brown ink
                      shadows: [
                        Shadow(color: Colors.white70, blurRadius: 2, offset: Offset(1, 1))
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppTranslations.get(appState.currentLanguage, 'total_xp')}: ${appState.score} XP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                    child: Divider(color: Color(0xFF8D6E63), thickness: 2),
                  ),
                ],
              ),
            ),
            
            // Quest List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: quests.length,
                itemBuilder: (context, index) {
                  final quest = quests[index];
                  final progressPercent = (quest.currentCount / quest.targetCount).clamp(0.0, 1.0);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.get(appState.currentLanguage, '${quest.id}_title'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            if (quest.isCompleted)
                              const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28)
                            else
                              Text(
                                '${quest.rewardXP} XP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD84315), // Red ink stamp color
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslations.get(appState.currentLanguage, '${quest.id}_desc'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  minHeight: 10,
                                  backgroundColor: const Color(0xFFD7CCC8),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    quest.isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '${quest.currentCount} / ${quest.targetCount}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
