class Quest {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  int currentCount;
  final int rewardXP;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.rewardXP,
  });

  bool get isCompleted => currentCount >= targetCount;

  void increment() {
    if (currentCount < targetCount) {
      currentCount++;
    }
  }
}
