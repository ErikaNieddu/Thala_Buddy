import 'package:flutter/material.dart' hide Step; 
import 'package:flutter/foundation.dart'; 
import '../services/impact.dart'; 
import '../models/steps.dart';    

class StepsProvider extends ChangeNotifier {
  
  List<Step> dailySteps = []; 
  bool isLoading = false;
  String? errorMessage;

  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  final Impact _impact = Impact();

  StepsProvider() {
    loadData();
  }

  int get totalStepsToday {
    return dailySteps.fold(0, (sum, step) => sum + step.value);
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
      dailySteps = await _impact.getStepsData(selectedDate);
    } catch (e) {
      errorMessage = 'Errore nel caricamento dei passi: $e';
      dailySteps = [];
      debugPrint('StepsProvider error: $e'); 
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}