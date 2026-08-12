import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../data/spots_db.dart';
import '../utils/translations.dart';

// 활성 퀘스트의 AI 최적 동선(plannedOrder)을 순서대로 보여주고,
// 방문한 곳은 체크 표시, 다음 목적지는 강조 표시한다.
class QuestRouteSheet extends StatelessWidget {
  final Quest quest;
  final String currentLang;

  const QuestRouteSheet({super.key, required this.quest, required this.currentLang});

  String _displayName(String rawTitle) {
    final cleanTarget = rawTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
        .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
        .trim();
    final detail = SpotsDB.get(cleanTarget);
    return detail != null ? detail.getName(currentLang) : rawTitle;
  }

  @override
  Widget build(BuildContext context) {
    final currentTargetTitle = quest.currentTargetSpot?['title']?.toString();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.route, color: Color(0xFF1F3864), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppTranslations.get(currentLang, 'quest_route_title'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F3864)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppTranslations.get(currentLang, '${quest.id}_title'),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (quest.plannedOrder.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                AppTranslations.get(currentLang, 'searching_target'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: quest.plannedOrder.length,
                itemBuilder: (context, index) {
                  final title = quest.plannedOrder[index];
                  final visited = quest.visitedSpotTitles.contains(title);
                  final isNext = !visited && title == currentTargetTitle;
                  final isLast = index == quest.plannedOrder.length - 1;
                  return _buildRouteItem(index, title, visited, isNext, isLast);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(int index, String title, bool visited, bool isNext, bool isLast) {
    final circleColor = visited
        ? const Color(0xFF2E7D32)
        : (isNext ? const Color(0xFFD4AF37) : Colors.grey[300]);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
                child: visited
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isNext ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE0DAD3))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Text(
                _displayName(title),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  color: visited ? Colors.grey : (isNext ? const Color(0xFF1F3864) : Colors.black87),
                  decoration: visited ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
