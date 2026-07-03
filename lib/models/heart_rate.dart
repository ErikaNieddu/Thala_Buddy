class HeartRate {
  final String date;
  final String time;
  final int value;
  final int confidence;

  HeartRate({
    required this.date,
    required this.time,
    required this.value,
    required this.confidence,
  });
  
  factory HeartRate.fromJson(String date, Map<String, dynamic> json) {
    return HeartRate(
      date: date,
      time: json['time'] ?? '00:00:00',
      value: (json['value'] as num?)?.toInt() ?? 0,           
      confidence: (json['confidence'] as num?)?.toInt() ?? 0, 
    );
  }

  @override
  String toString() {
    return 'HeartRate(date: $date, time: $time, value: $value, confidence: $confidence)';
  }
}