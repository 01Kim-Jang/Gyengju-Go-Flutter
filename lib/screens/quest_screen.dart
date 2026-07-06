import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_state.dart';
import '../utils/translations.dart';
import '../data/spots_db.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  void _showStampBook(BuildContext context, AppState appState) {
    final coreSpots = ['첨성대', '동궁과 월지', '불국사', '석굴암', '대릉원', '황리단길'];
    final currentLang = appState.currentLanguage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7), // Warm hanji style color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF8D6E63), width: 2),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 30),
                const SizedBox(width: 8),
                Text(
                  currentLang == 'ko' ? '경주 스탬프 북' : 'Gyeongju Stamp Book',
                  style: const TextStyle(
                    fontFamily: 'Serif', 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF3E2723),
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${currentLang == 'ko' ? '수집 현황' : 'Collected'}: ${appState.globalVisitedSpots.intersection(coreSpots.toSet()).length} / ${coreSpots.length}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF7D5A50), fontWeight: FontWeight.w600),
            ),
            const Divider(color: Color(0xFFD7CCC8), thickness: 1.5),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: coreSpots.length,
            itemBuilder: (context, index) {
              final spotName = coreSpots[index];
              final isCollected = appState.globalVisitedSpots.contains(spotName);
              return Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCollected ? const Color(0xFFFFF3E0) : Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCollected ? const Color(0xFFD4AF37) : Colors.grey[400]!,
                            width: 2.5,
                          ),
                          boxShadow: isCollected
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCollected
                              ? const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 36)
                              : const Icon(Icons.lock, color: Colors.grey, size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    spotName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCollected ? FontWeight.bold : FontWeight.normal,
                      color: isCollected ? const Color(0xFF3E2723) : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLang == 'ko' ? '닫기' : 'Close',
              style: const TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final quests = appState.quests;
    final activeQuest = quests.where((q) => q.isActive).firstOrNull;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hanji_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title Header with Stamp Book button in top-right
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        AppTranslations.get(appState.currentLanguage, 'quest_title'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          color: Color(0xFF3E2723),
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
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 36),
                      tooltip: appState.currentLanguage == 'ko' ? '스탬프 북' : 'Stamp Book',
                      onPressed: () => _showStampBook(context, appState),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
              child: Divider(color: Color(0xFF8D6E63), thickness: 2),
            ),
            
            // Active Quest Banner
            if (activeQuest != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF9A825)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.navigation, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          AppTranslations.get(appState.currentLanguage, '${activeQuest.id}_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (activeQuest.currentTargetSpot != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.place, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final rawTarget = activeQuest.currentTargetSpot!['title'] ?? '';
                                final cleanTarget = rawTarget
                                    .replaceAll(RegExp(r'\([^)]*\)'), '')
                                    .replaceAll(RegExp(r'\[[^\]]*\]'), '')
                                    .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
                                    .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
                                    .trim();
                                final targetDetail = SpotsDB.get(cleanTarget);
                                final targetDisplayName = targetDetail != null 
                                    ? targetDetail.getName(appState.currentLanguage) 
                                    : rawTarget;
                                return Text(
                                  '${AppTranslations.get(appState.currentLanguage, 'planner_current_target')}: $targetDisplayName',
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  maxLines: 2,
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                      if (appState.userLat != null && appState.userLng != null) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            double tLat = double.tryParse(activeQuest.currentTargetSpot!['mapY'].toString()) ?? 0;
                            double tLng = double.tryParse(activeQuest.currentTargetSpot!['mapX'].toString()) ?? 0;
                            double dist = _calculateDistance(appState.userLat!, appState.userLng!, tLat, tLng);
                            return Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Text(
                                '${AppTranslations.get(appState.currentLanguage, 'planner_distance')}: ${dist.toStringAsFixed(1)} km',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            );
                          }
                        )
                      ]
                    ] else ...[
                      const Text('목적지를 찾는 중입니다...', style: TextStyle(color: Colors.white)),
                    ]
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(color: Color(0xFF8D6E63), thickness: 1),
              ),
            ],

            // Quest List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: quests.length,
                itemBuilder: (context, index) {
                  final quest = quests[index];
                  // Hide active quest from the main list to avoid duplication
                  if (quest.isActive) return const SizedBox.shrink();

                  final progressPercent = (quest.currentCount / quest.targetCount).clamp(0.0, 1.0);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723)),
                            ),
                            if (quest.isCompleted)
                              const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28)
                            else if (quest.type == 'planner')
                              ElevatedButton(
                                onPressed: () {
                                  appState.setActiveQuest(quest.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(AppTranslations.get(appState.currentLanguage, 'planner_start')),
                              )
                            else
                              Text(
                                '${quest.rewardXP} XP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD84315),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslations.get(appState.currentLanguage, '${quest.id}_desc'),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  minHeight: 10,
                                  backgroundColor: const Color(0xFFEFEBE9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${quest.currentCount} / ${quest.targetCount}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a)); 
  }
}
