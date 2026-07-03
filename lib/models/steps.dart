class Step {
  final String date;
  final String time;
  final int value;

  Step({
    required this.date,
    required this.time,
    required this.value,
  });

  
  factory Step.fromJson(String date, Map<String, dynamic> json) {
    return Step(
      date: date,
      time: json['time'] ?? '00:00:00',
      value: int.parse(json['value']?.toString() ?? '0'),
    );
  }

  @override
  String toString() {
    return 'Step(date: $date, time: $time, value: $value)';
  }
}