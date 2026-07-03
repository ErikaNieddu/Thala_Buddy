import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import '../services/impact.dart';       
import '../models/sleep.dart';    

class SleepProvider extends ChangeNotifier {
  List<SleepSession> dailySleepSessions = []; 
  bool isLoading = false;
  String? errorMessage;

  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  final Impact _impact = Impact();

  SleepProvider() {
    loadData();
  }

  SleepSession? get mainSleepSession {
    if (dailySleepSessions.isEmpty) return null;
    try {
      return dailySleepSessions.firstWhere((session) => session.mainSleep == true);
    } catch (e) {
      return dailySleepSessions.reduce((curr, next) => 
          curr.duration > next.duration ? curr : next);
    }
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
      dailySleepSessions = await _impact.getSleepData(selectedDate);
    } catch (e) {
      errorMessage = 'Errore nel caricamento del sonno: ${e.toString()}';
      dailySleepSessions = [];
      debugPrint('SleepProvider error: $e'); 
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}