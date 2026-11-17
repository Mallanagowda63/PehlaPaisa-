/// Saver levels, unlocked by lifetime total saved.
enum UserLevel { beginner, saver, smartSaver, gullakMaster, legend }

/// Minimum total saved for each level.
const Map<UserLevel, int> levelThresholds = {
  UserLevel.beginner: 0,
  UserLevel.saver: 1000,
  UserLevel.smartSaver: 5000,
  UserLevel.gullakMaster: 10000,
  UserLevel.legend: 50000,
};

class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.next,
    required this.progress,
    required this.toNext,
  });

  final UserLevel level;

  /// Null at the top level.
  final UserLevel? next;

  /// 0..1 progress from this level to the next (1 at the top level).
  final double progress;

  /// Rupees still needed for the next level (0 at the top).
  final int toNext;
}

abstract final class Levels {
  static LevelProgress forTotal(int totalSaved) {
    const levels = UserLevel.values;
    var level = UserLevel.beginner;
    for (final l in levels) {
      if (totalSaved >= levelThresholds[l]!) level = l;
    }
    final i = levels.indexOf(level);
    if (i == levels.length - 1) {
      return LevelProgress(level: level, next: null, progress: 1, toNext: 0);
    }
    final next = levels[i + 1];
    final from = levelThresholds[level]!;
    final to = levelThresholds[next]!;
    return LevelProgress(
      level: level,
      next: next,
      progress: ((totalSaved - from) / (to - from)).clamp(0.0, 1.0),
      toNext: to - totalSaved,
    );
  }
}
