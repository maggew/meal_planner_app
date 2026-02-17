class _Sentinel {
  const _Sentinel();
}

enum TimerStatus { running, paused, finished }

class ActiveTimer {
  final String recipeId;
  final int stepIndex;
  final String label;
  final int totalSeconds;
  final int savedDurationSeconds;
  final DateTime? endTime;
  final int? pausedRemainingSeconds;
  final int notificationId;
  final TimerStatus status;

  ActiveTimer({
    required this.recipeId,
    required this.stepIndex,
    required this.label,
    required this.totalSeconds,
    required this.savedDurationSeconds,
    this.endTime,
    this.pausedRemainingSeconds,
    required this.notificationId,
    required this.status,
  });

  /// Unique Key für die Timer-Map im Notifier
  String get key => '$recipeId:$stepIndex';

  /// Verbleibende Sekunden berechnen (live aus endTime)
  int get remainingSeconds {
    if (status == TimerStatus.finished) return 0;
    if (status == TimerStatus.paused) return pausedRemainingSeconds ?? 0;
    if (endTime == null) return 0;

    final remaining = endTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Fortschritt als Wert zwischen 0.0 und 1.0
  double get progress {
    if (totalSeconds == 0) return 1.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  /// Ob der Timer abgelaufen ist
  bool get isExpired =>
      status == TimerStatus.running &&
      endTime != null &&
      DateTime.now().isAfter(endTime!);

  ActiveTimer copyWith({
    String? recipeId,
    int? stepIndex,
    String? label,
    int? totalSeconds,
    int? savedDurationSeconds,
    Object? endTime = const _Sentinel(),
    Object? pausedRemainingSeconds = const _Sentinel(),
    int? notificationId,
    TimerStatus? status,
  }) {
    return ActiveTimer(
      recipeId: recipeId ?? this.recipeId,
      stepIndex: stepIndex ?? this.stepIndex,
      label: label ?? this.label,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      savedDurationSeconds: savedDurationSeconds ?? this.savedDurationSeconds,
      endTime: endTime is _Sentinel ? this.endTime : endTime as DateTime?,
      pausedRemainingSeconds: pausedRemainingSeconds is _Sentinel
          ? this.pausedRemainingSeconds
          : pausedRemainingSeconds as int?,
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
    );
  }
}
