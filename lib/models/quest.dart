class Quest {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  int currentCount;
  final int rewardXP;
  
  // Planner Quest additions
  final String type; // 'basic' or 'planner'
  final List<String> keywords;
  bool isActive;
  Map<String, dynamic>? currentTargetSpot;
  List<String> visitedSpotTitles;
  // 현재 위치 기준으로 계산된 최적 방문 순서 (제목 목록). setActiveQuest 시점에 1회 계산됨.
  List<String> plannedOrder;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.rewardXP,
    this.type = 'basic',
    this.keywords = const [],
    this.isActive = false,
    this.currentTargetSpot,
    List<String>? visitedSpotTitles,
    List<String>? plannedOrder,
  })  : visitedSpotTitles = visitedSpotTitles ?? [],
        plannedOrder = plannedOrder ?? [];

  bool get isCompleted => currentCount >= targetCount;

  void increment() {
    if (currentCount < targetCount) {
      currentCount++;
    }
  }

  void addVisitedSpot(String title) {
    if (!visitedSpotTitles.contains(title)) {
      visitedSpotTitles.add(title);
      increment();
    }
  }
}
