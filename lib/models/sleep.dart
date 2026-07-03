class SleepSession {
  final String dateOfSleep;
  final int duration;
  final int minutesAsleep;
  final bool mainSleep;

  SleepSession({
    required this.dateOfSleep,
    required this.duration,
    required this.minutesAsleep,
    required this.mainSleep,
  });

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      dateOfSleep: json['dateOfSleep'] ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0, 
      minutesAsleep: (json['minutesAsleep'] as num?)?.toInt() ?? 0,
      mainSleep: json['mainSleep'] ?? false,
    );
  }

  @override
  String toString() {
    return 'SleepSession(date: $dateOfSleep, duration: $duration ms, minutesAsleep: $minutesAsleep, mainSleep: $mainSleep)';
  }
}