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
  }) : visitedSpotTitles = visitedSpotTitles ?? [];

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
