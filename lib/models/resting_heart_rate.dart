class RestingHeartRate {
  final String date;
  final String time;
  final double value;
  final double error;

  RestingHeartRate({
    required this.date,
    required this.time,
    required this.value,
    required this.error,
  });

  factory RestingHeartRate.fromJson(String date, Map<String, dynamic> json) {
    return RestingHeartRate(
      date: date,
      time: json['time'] ?? '00:00:00',
      value: (json['value'] as num?)?.toDouble() ?? 0.0, 
      error: (json['error'] as num?)?.toDouble() ?? 0.0, 
    );
  }

  @override
  String toString() {
    return 'RestingHeartRate(date: $date, time: $time, value: $value, error: $error)';
  }
}
