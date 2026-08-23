import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_state.dart';
import '../utils/translations.dart';
import '../data/spots_db.dart';
import '../widgets/quest_route_sheet.dart';
import '../utils/transit_helper.dart';
import 'trip_report_screen.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  // 문화 예절 팁이 등록된 테마 퀘스트 (해당 quest.id + '_tip' 번역 키 사용)
  static const Set<String> _etiquetteTipQuestIds = {
    'planner_temple',
    'planner_tomb',
    'planner_historic',
    'planner_art',
  };

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
                  AppTranslations.get(currentLang, 'stamp_book'),
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
              '${AppTranslations.get(currentLang, 'collected')}: ${appState.globalVisitedSpots.intersection(coreSpots.toSet()).length} / ${coreSpots.length}',
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
                    SpotsDB.get(spotName)?.getName(currentLang) ?? spotName,
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
              AppTranslations.get(currentLang, 'close'),
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
            // Title Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppTranslations.get(appState.currentLanguage, 'total_xp')}: ${appState.score} XP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showStampBook(context, appState),
                        icon: const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 20),
                        label: Text(
                          AppTranslations.get(appState.currentLanguage, 'stamp_book'),
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8D6E63), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: const Color(0xFFFFFDF9).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TripReportScreen()),
                      ),
                      icon: const Icon(Icons.menu_book, color: Color(0xFF1F3864), size: 18),
                      label: Text(
                        AppTranslations.get(appState.currentLanguage, 'trip_report'),
                        style: const TextStyle(color: Color(0xFF1F3864), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F3864), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        backgroundColor: const Color(0xFFFFFDF9).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
              child: Divider(color: Color(0xFF8D6E63), thickness: 2),
            ),
            
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
                    InkWell(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => QuestRouteSheet(
                          quest: activeQuest,
                          currentLang: appState.currentLanguage,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.navigation, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppTranslations.get(appState.currentLanguage, '${activeQuest.id}_title'),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Tooltip(
                                message: AppTranslations.get(appState.currentLanguage, 'view_full_route'),
                                child: const Icon(Icons.chevron_right, color: Colors.white70),
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
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                            if (appState.userLat != null && appState.userLng != null) ...[
                              const SizedBox(height: 6),
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
                              ),
                            ],
                          ] else ...[
                            Text(AppTranslations.get(appState.currentLanguage, 'searching_target'), style: const TextStyle(color: Colors.white)),
                          ],
                        ],
                      ),
                    ),
                    if (activeQuest.currentTargetSpot != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInCardModeButton(
                            icon: Icons.directions_walk,
                            label: AppTranslations.get(appState.currentLanguage, 'walk'),
                            onTap: () {
                              appState.setNavigationMode('walk');
                              appState.setCurrentTabIndex(1);
                            },
                          ),
                          _buildInCardModeButton(
                            icon: Icons.directions_car,
                            label: AppTranslations.get(appState.currentLanguage, 'drive'),
                            onTap: () {
                              appState.setNavigationMode('drive');
                              appState.setCurrentTabIndex(1);
                            },
                          ),
                          _buildInCardModeButton(
                            icon: Icons.directions_bus,
                            label: AppTranslations.get(appState.currentLanguage, 'transit'),
                            onTap: () {
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
                              final targetLat = double.tryParse(activeQuest.currentTargetSpot!['mapY'].toString()) ?? 35.8348;
                              final targetLng = double.tryParse(activeQuest.currentTargetSpot!['mapX'].toString()) ?? 129.2266;

                              appState.startTransitAlert();
                              openTransitInfoSheet(
                                context,
                                targetDisplayName: targetDisplayName,
                                lat: targetLat,
                                lng: targetLng,
                                currentLang: appState.currentLanguage,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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

                  final isMvpCourse = ['c_royal', 'c_buddha', 'c_munmu'].contains(quest.id);
                  final progressPercent = (quest.currentCount / quest.targetCount).clamp(0.0, 1.0);
                  
                  String transportBadge = AppTranslations.get(appState.currentLanguage, 'transport_badge_walk');
                  if (quest.id == 'c_buddha') transportBadge = AppTranslations.get(appState.currentLanguage, 'transport_badge_bus');
                  if (quest.id == 'c_munmu') transportBadge = AppTranslations.get(appState.currentLanguage, 'transport_badge_drive');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMvpCourse 
                          ? const Color(0xFFFFFDF7) 
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMvpCourse ? const Color(0xFFD4AF37) : const Color(0xFF8D6E63), 
                        width: isMvpCourse ? 2.2 : 1.5,
                      ),
                      boxShadow: isMvpCourse
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMvpCourse) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F3864),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  AppTranslations.get(appState.currentLanguage, 'mvp_course_badge'),
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE65100), width: 0.8),
                                ),
                                child: Text(
                                  transportBadge,
                                  style: const TextStyle(color: Color(0xFFE65100), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppTranslations.get(appState.currentLanguage, '${quest.id}_title'),
                                style: TextStyle(
                                  fontSize: isMvpCourse ? 19 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: isMvpCourse ? const Color(0xFF1F3864) : const Color(0xFF3E2723),
                                ),
                              ),
                            ),
                            if (quest.isCompleted)
                              const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28)
                            else if (quest.type == 'planner')
                              ElevatedButton.icon(
                                onPressed: () {
                                  appState.setActiveQuest(quest.id);
                                  appState.setCurrentTabIndex(1); // Auto switch to Map tab
                                },
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: Text(AppTranslations.get(appState.currentLanguage, 'planner_start')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMvpCourse ? const Color(0xFF1F3864) : const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  elevation: isMvpCourse ? 3 : 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
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
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF5D4037)),
                        ),
                        if (_etiquetteTipQuestIds.contains(quest.id)) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    AppTranslations.get(appState.currentLanguage, '${quest.id}_tip'),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF7D5A50), height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isMvpCourse ? const Color(0xFF1F3864) : const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${quest.currentCount} / ${quest.targetCount}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isMvpCourse ? const Color(0xFF1F3864) : const Color(0xFF3E2723),
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

  Widget _buildInCardModeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white54, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
