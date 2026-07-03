import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../providers/resting_heart_rate_provider.dart';
import '../providers/heart_rate_provider.dart';
import '../providers/steps_provider.dart';
import '../providers/sleep_provider.dart';

import 'calendar.dart';
import 'profile.dart'; 
import 'travel.dart'; 
import 'report.dart'; 

class Home extends StatefulWidget {
  static const route = '/home/';
  static const routeDisplayName = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  
  String userName = 'User';
  String userGender = 'M';
  double userHeight = 170.0;
  double userWeight = 70.0;
  int userAge = 25; 

  // Reminder pop-up
  String? _tomorrowEventMessage;
  bool _showTopAlert = false;

  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);
  static const Color cardBackground = Colors.white; 
  static const Color scaffoldBackground = Color(0xFFF2F4F7); 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
    _checkTomorrowAppointments(); 
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = sp.getString('name') ?? 'User';
        userGender = sp.getString('gender') ?? 'M';
        userHeight = double.tryParse(sp.getString('height') ?? '170') ?? 170.0;
        userWeight = double.tryParse(sp.getString('weight') ?? '70') ?? 70.0;
        
        String dobString = sp.getString('dob') ?? '';
        if (dobString.isNotEmpty) {
          try {
            final parts = dobString.split('/');
            final birthYear = int.parse(parts[2]);
            userAge = DateTime.now().year - birthYear;
          } catch (e) {
            userAge = 25; 
          }
        }
      });
    }
  }

  Future<void> _checkTomorrowAppointments() async {
    final sp = await SharedPreferences.getInstance();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    String dateKey = "events_${DateFormat('yyyy-MM-dd').format(tomorrow)}";
    
    List<String>? events = sp.getStringList(dateKey);

    if (events != null && events.isNotEmpty) {
      String allEventsText = events.map((e) => "• $e").join('\n'); 
      if (mounted) {
        setState(() {
          _tomorrowEventMessage = "Reminder! Tomorrow you have:\n$allEventsText";
          _showTopAlert = true; 
        });
      }
    }
  }

  void _handleDateChange(BuildContext context, int delta) {
    context.read<RestingHeartRateProvider>().changeDay(delta);
    context.read<HeartRateProvider>().changeDay(delta);
    context.read<StepsProvider>().changeDay(delta);
    context.read<SleepProvider>().changeDay(delta);
  }

  Future<void> _selectDateFromCalendar(BuildContext context, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020), 
      lastDate: DateTime.now().add(const Duration(days: 365)), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryRed,       
              onPrimary: Colors.white,    
              onSurface: Colors.black87,  
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final DateTime currentMidnight = DateTime(currentDate.year, currentDate.month, currentDate.day);
      final DateTime pickedMidnight = DateTime(picked.year, picked.month, picked.day);
      final int delta = pickedMidnight.difference(currentMidnight).inDays;
      
      if (delta != 0 && mounted) {
        _handleDateChange(context, delta);
      }
    }
  }

  void _showInfoDialog(BuildContext context, String title, String description, {String? referenceValues}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 24.0, left: 24.0, right: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: primaryRed, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                    ),
                    if (referenceValues != null) ...[
                      const SizedBox(height: 12), 
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, color: Colors.grey.shade700, size: 20), 
                          const SizedBox(width: 6),
                          Text(
                            'Reference Values:',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        referenceValues,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                    ]
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 24), 
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatus(double val, double low, double high, bool isHigherBetter) {
    if (val == 0.0) return {'text': 'No data', 'textColor': Colors.grey, 'bgColor': Colors.grey.shade200};
    
    bool isOptimal = isHigherBetter ? (val >= high) : (val <= low);
    bool isBad = isHigherBetter ? (val < low) : (val > high);

    if (isOptimal) return {'text': 'Optimal', 'textColor': Colors.green.shade700, 'bgColor': Colors.green.shade100};
    if (isBad) return {'text': 'Attention', 'textColor': Colors.red.shade700, 'bgColor': Colors.red.shade100};
    return {'text': 'Average', 'textColor': Colors.orange.shade800, 'bgColor': Colors.orange.shade100};
  }

  String _getBuddyMessage(Map hrr, Map effort, Map sleep) {
    if (hrr['text'] == 'No data') {
      return "Hi! Sync yesterday's data to get your personalized insights for today.";
    }
    if (hrr['text'] == 'Attention') {
      return "Your heart worked harder than usual yesterday. Please prioritize rest and avoid stress today.";
    }
    if (effort['text'] == 'Attention') {
      return "You put a lot of effort into your steps yesterday! Make sure to take breaks today if you feel tired.";
    }
    if (sleep['text'] == 'Attention') {
      return "Looks like you didn't recover well last night. Consider taking a quick nap to get through today!";
    }
    if (hrr['text'] == 'Optimal' && effort['text'] == 'Optimal') {
      return "Great job! Yesterday's vitals were perfectly balanced. Keep up the healthy habits today!";
    }
    return "Yesterday's data looks okay! Stay hydrated and listen to your body today.";
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildDateSelector(BuildContext context, RestingHeartRateProvider providerHome) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: primaryRed, size: 28), 
            onPressed: () => _handleDateChange(context, -1),
          ),
          InkWell(
            onTap: () => _selectDateFromCalendar(context, providerHome.selectedDate),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEE, d MMM yyyy').format(providerHome.selectedDate),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryRed),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.calendar_today, size: 14, color: primaryRed),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: primaryRed, size: 28), 
            onPressed: () => _handleDateChange(context, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final providerHome = context.watch<RestingHeartRateProvider>();
    final providerHR = context.watch<HeartRateProvider>();
    final providerSteps = context.watch<StepsProvider>();
    final providerSleep = context.watch<SleepProvider>();

    final isLoading = providerHome.isLoading || providerHR.isLoading || providerSteps.isLoading || providerSleep.isLoading;
    final errorMessage = providerHome.errorMessage ?? providerHR.errorMessage ?? providerSteps.errorMessage ?? providerSleep.errorMessage;

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final selectedMidnight = DateTime(providerHome.selectedDate.year, providerHome.selectedDate.month, providerHome.selectedDate.day);
    final isFutureDate = selectedMidnight.isAfter(todayMidnight);

    double averageHr = 0.0, sleepHours = 0.0, effortIndex = 0.0, recoveryScore = 0.0, hrrToday = 0.0;
    
    if (providerHR.dailyData.isNotEmpty) {
      final totalBpm = providerHR.dailyData.fold(0, (sum, hr) => sum + hr.value);
      averageHr = totalBpm / providerHR.dailyData.length;
    }
    if (providerSleep.mainSleepSession != null) {
      sleepHours = providerSleep.mainSleepSession!.minutesAsleep / 60.0;
    }
    if (providerHome.restingHeartRate != null && providerSteps.totalStepsToday > 0 && averageHr > 0) {
      final rhr = providerHome.restingHeartRate!.value;
      final stepsFactor = providerSteps.totalStepsToday / 1000.0;
      if (stepsFactor > 0) {
        effortIndex = math.max(0.0, (averageHr - rhr) / stepsFactor);
      }
    }
    if (providerHome.restingHeartRate != null && providerHome.restingHeartRate!.value > 0 && sleepHours > 0) {
      recoveryScore = (sleepHours / providerHome.restingHeartRate!.value) * 100;
    }
    
    final double hrMax = 220.0 - userAge; 
    if (providerHome.restingHeartRate != null && providerHome.restingHeartRate!.value > 0) {
      hrrToday = hrMax - providerHome.restingHeartRate!.value;
    }

    Map<String, double> weeklyHrrData = {};
    if (providerHome.weeklyRhrData.isNotEmpty) {
      providerHome.weeklyRhrData.forEach((dateKey, rhrValue) {
        weeklyHrrData[dateKey] = hrMax - rhrValue;
      });
    }

    double avgHrr = 0, minHrr = 0, maxHrr = 0;
    if (weeklyHrrData.isNotEmpty) {
      final values = weeklyHrrData.values.toList();
      minHrr = values.reduce(math.min);
      maxHrr = values.reduce(math.max);
      avgHrr = values.reduce((a, b) => a + b) / values.length;
    }

    double bmi = userWeight / ((userHeight / 100) * (userHeight / 100));
    double effortTLow = 3.0, effortTHigh = 5.0;
    if (userGender == 'F') { effortTLow += 0.5; effortTHigh += 0.5; }
    if (bmi > 25.0) { effortTLow += 0.3; effortTHigh += 0.3; }

    double sleepTLow = 7.0, sleepTHigh = 10.0;
    if (userAge > 50 || bmi > 25.0) { sleepTLow -= 1.0; sleepTHigh -= 1.0; }

    final effortStatus = _getStatus(effortIndex, effortTLow, effortTHigh, false);
    final sleepStatus = _getStatus(recoveryScore, sleepTLow, sleepTHigh, true);
    final hrrStatus = _getStatus(hrrToday, 70.0, 100.0, true);
    final avgHrrStatus = _getStatus(avgHrr, 70.0, 100.0, true);

    String buddyMessage = _getBuddyMessage(hrrStatus, effortStatus, sleepStatus);

    const String effortDesc = 
        "This index measures how hard your heart works during your daily steps compared to its resting baseline. "
        "In thalassemia, a drop in hemoglobin during the pre-transfusion phase causes the heart to accelerate noticeably "
        "even during a short walk. This metric tracks that cardiac 'overheating'.";
    const String effortRef = "• Excellent: < 1 pts\n• Normal Range: 1 - 5 pts";
        
    const String sleepDesc = 
        "This score evaluates the efficiency of your night's rest. "
        "Severe anemia can cause nocturnal hypoxia, forcing the heart to beat heavily during sleep. "
        "This prevents true recovery and leads to the classic chronic morning fatigue.";
    const String sleepRef = "• Excellent: > 15 pts\n• Normal Range: 8.5 - 15 pts";

    const String hrrDesc = 
        "The Heart Rate Reserve (HRR) evaluates your capacity to tolerate physical effort without experiencing early fatigue. "
        "It is calculated as the difference between your estimated maximum heart rate and your resting heart rate.";
    const String hrrRef = "• Normal/Optimal: > 100 bpm\n• Reduced Reserve: < 100 bpm";

    const String chartDescription = 
        "This chart displays the trend of your Heart Rate Reserve (HRR) over the last 7 days.";

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal), 
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black), 
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
                    _loadUserData(); 
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryRed.withOpacity(0.1),
                    child: const Icon(Icons.person, color: primaryRed, size: 28),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryRed),
                    SizedBox(height: 16),
                    Text('Syncing vitals...', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 10.0, bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFutureDate) ...[
                      _buildDateSelector(context, providerHome),
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.hourglass_empty, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Data for this date is not\navailable yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      )
                    ] else ...[
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(errorMessage, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                              ],
                            ),
                          ),
                        ),

                      // Buddy message
                      Container(
                        padding: const EdgeInsets.all(24), 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24), 
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/logo2.jpeg',
                                width: 90, 
                                height: 90,
                                fit: BoxFit.contain, 
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 90, height: 90, color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey, size: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                '"$buddyMessage"',
                                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87, height: 1.5), 
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildDateSelector(context, providerHome),
                      const SizedBox(height: 20), 
                    
                      const Text(
                        'Clinical History Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), 
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildGridCard(
                              title: 'Effort Index',
                              valueStr: effortIndex.toStringAsFixed(1),
                              unit: 'pts',
                              statusMap: effortStatus,
                              imagePath: 'assets/battery.jpg',
                              iconBgColor: Colors.orange.shade50,
                              animationType: AnimationStyle.shake, 
                              onTap: () => _showInfoDialog(context, 'Effort Index', effortDesc, referenceValues: effortRef),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGridCard(
                              title: 'Sleep Score',
                              valueStr: recoveryScore.toStringAsFixed(0),
                              unit: 'pts', 
                              statusMap: sleepStatus,
                              imagePath: 'assets/moon.jpg',
                              iconBgColor: Colors.indigo.shade50,
                              animationType: AnimationStyle.float, 
                              onTap: () => _showInfoDialog(context, 'Sleep Score', sleepDesc, referenceValues: sleepRef),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Heart rate reserve card
                      _buildMainCard(
                        title: 'Heart Rate Reserve',
                        valueStr: providerHome.restingHeartRate != null ? hrrToday.toStringAsFixed(0) : '-',
                        unit: 'bpm',
                        statusMap: hrrStatus,
                        imagePath: 'assets/heart.jpg',
                        iconBgColor: Colors.red.shade50,
                        animationType: AnimationStyle.pulse, 
                        onTap: () => _showInfoDialog(context, 'Heart Rate Reserve', hrrDesc, referenceValues: hrrRef),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '7-Day HRR Trend',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          if (weeklyHrrData.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: avgHrrStatus['bgColor'], borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                avgHrrStatus['text'],
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: avgHrrStatus['textColor']),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12), 

                      InkWell(
                        onTap: () => _showInfoDialog(context, '7-Day HRR Trend', chartDescription), 
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBackground,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 180, 
                                width: double.infinity,
                                padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 5),
                                child: weeklyHrrData.isEmpty
                                    ? const Center(child: Text('No data available', style: TextStyle(color: Colors.black38)))
                                    : CustomPaint(
                                        painter: _SmoothChartPainter(
                                          entries: weeklyHrrData.entries.toList(),
                                          maxVal: maxHrr + 5,
                                          minVal: (minHrr - 5).clamp(0, double.infinity),
                                        ),
                                      ), 
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(color: Colors.black12, height: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildChartStat('Average', avgHrr),
                                    _buildChartStat('Minimum', minHrr),
                                    _buildChartStat('Maximum', maxHrr),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String valueStr,
    required String unit,
    required Map<String, dynamic> statusMap,
    required String imagePath,
    required Color iconBgColor,
    required AnimationStyle animationType,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedDashboardImage(
                imagePath: imagePath, 
                size: 60, 
                style: animationType,
                bgColor: iconBgColor,
              ),
            ),
            const SizedBox(width: 20), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4), 
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(valueStr, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.black)), 
                      const SizedBox(width: 6),
                      Text(unit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black38)),
                    ],
                  ),
                  const SizedBox(height: 8), 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusMap['bgColor'], borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        statusMap['text'],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusMap['textColor']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String valueStr,
    required String unit,
    required Map<String, dynamic> statusMap,
    required String imagePath,
    required Color iconBgColor,
    required AnimationStyle animationType,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6), 
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12), 
              ),
              child: AnimatedDashboardImage(
                imagePath: imagePath, 
                size: 36, 
                style: animationType,
                bgColor: iconBgColor,
              ),
            ),
            const SizedBox(height: 8), 
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2), 
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(valueStr, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.black)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38)),
              ],
            ),
            const SizedBox(height: 6), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusMap['bgColor'], borderRadius: BorderRadius.circular(12)),
              child: Text(
                statusMap['text'],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusMap['textColor']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartStat(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        const Text('BPM', style: TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0: bodyContent = _buildHomeBody(context); break;
      case 1: bodyContent = const CalendarScreen(); break; 
      case 2: bodyContent = const TravelScreen(); break; 
      case 3: bodyContent = const ReportScreen(); break; 
      default: bodyContent = _buildHomeBody(context);
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final alertTopPosition = _showTopAlert ? topPadding + 16 : -150.0;

    return Scaffold(
      backgroundColor: scaffoldBackground, 
      extendBody: false, 
      body: Stack(
        children: [
          bodyContent,
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            top: alertTopPosition,
            left: 16,
            right: 16,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(20),
              color: Colors.indigo.shade600, 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.event_available, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _tomorrowEventMessage ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showTopAlert = false),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), 
              blurRadius: 10, 
              offset: const Offset(0, -4), 
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'), 
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff_rounded), label: 'Travel'),
            BottomNavigationBarItem(icon: Icon(Icons.medical_information_rounded), label: 'Report'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: primaryRed,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

enum AnimationStyle { pulse, float, shake }

class AnimatedDashboardImage extends StatefulWidget {
  final String imagePath;
  final double size;
  final AnimationStyle style;
  final Color? bgColor; 

  const AnimatedDashboardImage({
    super.key, 
    required this.imagePath, 
    required this.size,
    required this.style,
    this.bgColor,
  });

  @override
  State<AnimatedDashboardImage> createState() => _AnimatedDashboardImageState();
}

class _AnimatedDashboardImageState extends State<AnimatedDashboardImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    int durationMs = widget.style == AnimationStyle.pulse ? 800 : (widget.style == AnimationStyle.float ? 2000 : 300);
    _controller = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget baseImage = Image.asset(
          widget.imagePath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain, 
          color: widget.bgColor, 
          colorBlendMode: widget.bgColor != null ? BlendMode.multiply : null, 
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: widget.size, color: Colors.grey),
        );

        Widget zoomedImage = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.scale(
            scale: 1.45, 
            child: baseImage,
          ),
        );

        if (widget.style == AnimationStyle.pulse) {
          double scale = 1.0 + (_controller.value * 0.15);
          return Transform.scale(scale: scale, child: zoomedImage);
        } else if (widget.style == AnimationStyle.float) {
          double dy = -3.0 + (_controller.value * 6.0);
          return Transform.translate(offset: Offset(0, dy), child: zoomedImage);
        } else {
          double angle = -0.05 + (_controller.value * 0.1);
          return Transform.rotate(angle: angle, child: zoomedImage);
        }
      },
    );
  }
}

class _SmoothChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double maxVal;
  final double minVal;

  _SmoothChartPainter({
    required this.entries,
    required this.maxVal,
    required this.minVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    
    const Color primaryRed = Color.fromARGB(255, 183, 38, 38);
    const double leftPadding = 30;
    const double bottomPadding = 24;
    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;
    final double range = maxVal - minVal;

    final linePaint = Paint()
      ..color = primaryRed 
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    final dotBorderPaint = Paint()
      ..color = primaryRed 
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final filledDotPaint = Paint()
      ..color = primaryRed
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = chartHeight - (chartHeight * i / 3);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      final val = minVal + (range * i / 3);
      _drawText(canvas, val.toStringAsFixed(0), Offset(0, y - 6), fontSize: 10);
    }

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = leftPadding + (chartWidth * i / (entries.length - 1));
      final normalized = range == 0 ? 0.5 : (entries[i].value - minVal) / range;
      final y = chartHeight - (chartHeight * normalized);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        canvas.drawCircle(points[i], 5, dotPaint);
        canvas.drawCircle(points[i], 5, dotBorderPaint);
      } else {
        canvas.drawCircle(points[i], 4, filledDotPaint);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, {double fontSize = 10}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey, fontSize: fontSize, fontWeight: FontWeight.w500),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SmoothChartPainter oldDelegate) =>
      oldDelegate.entries != entries;
}
