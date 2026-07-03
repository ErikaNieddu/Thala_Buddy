import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import '../services/impact.dart';       
import '../models/resting_heart_rate.dart'; 

class RestingHeartRateProvider extends ChangeNotifier {
  RestingHeartRate? restingHeartRate;   
  Map<String, double> weeklyRhrData = {};
  bool isLoading = false;
  String? errorMessage;

  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  final Impact _impact = Impact();

  RestingHeartRateProvider() {
    loadData();
  }

  void changeDay(int delta) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final candidate = selectedDate.add(Duration(days: delta));
    final candidateMidnight = DateTime(candidate.year, candidate.month, candidate.day);

    if (candidateMidnight.isAfter(todayMidnight)) return;

    selectedDate = candidate;
    loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    errorMessage = null;

    try {
      restingHeartRate = await _impact.getRHRData(selectedDate);
      weeklyRhrData = await _impact.getRHRWeeklyData(selectedDate, days: 7);
    } catch (e) {
      errorMessage = 'Errore nel caricamento dati: ${e.toString()}';
      restingHeartRate = null;
      weeklyRhrData = {};
      debugPrint('RestingHeartRateProvider error: $e'); 
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}