import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(); 
  DateTime _currentMonth = DateTime.now(); 
  
  List<String> _dayEvents = []; 
  
  Set<int> _daysWithTransfusions = {};
  Set<int> _daysWithCheckups = {};

  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);

  @override
  void initState() {
    super.initState();
    _loadMonthData(); 
  }

  Future<void> _loadMonthData() async {
    final sp = await SharedPreferences.getInstance();
    Set<int> transfusions = {};
    Set<int> checkups = {};

    int totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    for (int i = 1; i <= totalDays; i++) {
      String dateKey = "events_${DateFormat('yyyy-MM-dd').format(DateTime(_currentMonth.year, _currentMonth.month, i))}";
      List<String>? events = sp.getStringList(dateKey);
      
      if (events != null && events.isNotEmpty) {
        for (var event in events) {
          if (event.contains("Transfusion")) {
            transfusions.add(i);
          } else if (event.contains("Medical Check-up")) {
            checkups.add(i);
          }
        }
      }
    }

    String focusedKey = "events_${DateFormat('yyyy-MM-dd').format(_focusedDay)}";
    List<String> focusedEvents = sp.getStringList(focusedKey) ?? [];

    if (!mounted) return;

    setState(() {
      _daysWithTransfusions = transfusions;
      _daysWithCheckups = checkups;
      _dayEvents = focusedEvents;
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment, 1);
    });
    _loadMonthData();
  }

  Future<void> _deleteAppointment(int index) async {
    final sp = await SharedPreferences.getInstance();
    String dateKey = "events_${DateFormat('yyyy-MM-dd').format(_focusedDay)}";
    
    List<String> currentEvents = List.from(_dayEvents);
    currentEvents.removeAt(index);
    
    if (currentEvents.isEmpty) {
      await sp.remove(dateKey);
    } else {
      await sp.setStringList(dateKey, currentEvents);
    }
    
    _loadMonthData();
  }

  void _openAddEventScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(selectedDate: _focusedDay),
      ),
    );
    if (result == true) {
      _loadMonthData();
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    int emptySlots = firstWeekday - 1; 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Text(
                  'Personal Calendar', 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
                ),
                const SizedBox(height: 8),
                const Text(
                  'Calendar for planning medical checkups and transfusion therapies.', 
                  style: TextStyle(fontSize: 16, color: Colors.black54)
                ),
                const SizedBox(height: 24),
                
                // --- CALENDAR GRID ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: primaryRed),
                            onPressed: () => _changeMonth(-1),
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(_currentMonth),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryRed),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: primaryRed),
                            onPressed: () => _changeMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                          return Container(
                            alignment: Alignment.center,
                            width: 32,
                            child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, fontSize: 12)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalDays + emptySlots,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4, 
                          crossAxisSpacing: 6,
                        ),
                        itemBuilder: (context, index) {
                          if (index < emptySlots) {
                            return const SizedBox.shrink(); 
                          }

                          int dayNumber = index - emptySlots + 1;
                          DateTime dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                          
                          bool isSelected = dayDate.year == _focusedDay.year &&
                                            dayDate.month == _focusedDay.month &&
                                            dayDate.day == _focusedDay.day;

                          bool hasTransfusion = _daysWithTransfusions.contains(dayNumber);
                          bool hasCheckup = _daysWithCheckups.contains(dayNumber);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _focusedDay = dayDate;
                              });
                              _loadMonthData();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? primaryRed : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$dayNumber",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (hasTransfusion)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : primaryRed,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (hasCheckup)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.indigo,
                                            shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24), 
                
                Text(
                  "Appointments for ${DateFormat('d MMM yyyy').format(_focusedDay)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _dayEvents.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16), 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            const Text(
                              "No appointments scheduled for this day.\nTap the '+ Add' button below to schedule one.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic, fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryRed,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                              ),
                              onPressed: _openAddEventScreen,
                              child: const Text(
                                "+ Add", 
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dayEvents.length,
                        itemBuilder: (context, index) {
                          final eventText = _dayEvents[index];
                          final isTransfusion = eventText.contains("Transfusion");

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                              ],
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isTransfusion ? primaryRed.withOpacity(0.1) : Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isTransfusion ? Icons.bloodtype : Icons.assignment,
                                  color: isTransfusion ? primaryRed : Colors.indigo,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                eventText,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.black38),
                                tooltip: 'Remove appointment',
                                onPressed: () => _deleteAppointment(index),
                              ),
                            ),
                          );
                        },
                      ),
                
                if (_dayEvents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _openAddEventScreen,
                      child: const Text(
                        "+ Add Another Appointment",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AddEventScreen({super.key, required this.selectedDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  String _selectedType = "Medical Check-up";
  TimeOfDay _selectedTime = TimeOfDay.now();

  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);

  Future<void> _saveAppointment() async {
    final sp = await SharedPreferences.getInstance();
    String dateKey = "events_${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}";
    
    List<String> currentEvents = sp.getStringList(dateKey) ?? [];
    String formattedTime = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";
    currentEvents.add("$_selectedType at $formattedTime");
    
    await sp.setStringList(dateKey, currentEvents);
    
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Appointment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Event Type:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ["Medical Check-up", "Transfusion"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 24),
            const Text("Select Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _selectedTime);
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedTime.format(context), style: const TextStyle(fontSize: 18)),
                    const Icon(Icons.access_time, color: primaryRed),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                onPressed: _saveAppointment,
                child: const Text("Save Appointment", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}