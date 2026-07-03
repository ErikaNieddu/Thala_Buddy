import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import '../services/impact.dart';       
import '../models/heart_rate.dart';     

class HeartRateProvider extends ChangeNotifier {
  List<HeartRate> dailyData = [];       
  bool isLoading = false;
  String? errorMessage;

  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  final Impact _impact = Impact();

  HeartRateProvider() {
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
      dailyData = await _impact.getHeartRateData(selectedDate);
      
    } catch (e) {
      errorMessage = 'Errore nel caricamento dati Heart Rate: ${e.toString()}';
      dailyData = [];
      debugPrint('HeartRateProvider error: $e'); 
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}