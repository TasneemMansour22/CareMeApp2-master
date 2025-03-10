import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test1/screens/notification_service.dart';
import 'package:uuid/uuid.dart';

class AddMedicationScreen extends StatefulWidget {
  final String seniorId;
  final Map<String, dynamic>? medication;

  AddMedicationScreen({required this.seniorId, required  this.medication, });

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedFrequency = "Every Day"; // Default frequency
  String _selectedTimesPerDay = "Once"; // Default times per day
  final List<String> _frequencyOptions = ["Every Day", "Every Other Day", "Weekly"];
  final List<String> _timesPerDayOptions = ["Once", "Twice", "Thrice"];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // To store selected time
  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!['medication_name'] ?? '';
      _dosageController.text = widget.medication!['dosage'] ?? '';
      _selectedFrequency = widget.medication!['frequency'] ?? 'Every Day';
      _selectedTimesPerDay = widget.medication!['times_per_day'] ?? 'Once';
      _selectedDate = (widget.medication!['start_date'] as Timestamp?)?.toDate();
      _selectedTime = _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : null;
      _noteController.text = widget.medication!['note'] ?? '';
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF308A99), // Highlight color (selected date and buttons)
              onPrimary: Colors.white, // Text color on primary color
              onSurface: Colors.black, // Default text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF308A99), // Highlight color (clock dial and buttons)
              onPrimary: Colors.white, // Text color on primary color
              onSurface: Colors.black, // Default text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _addMedication() async {
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    String medicationId;
    if (widget.medication == null) {
      // Adding a new medicine
      medicationId = Uuid().v4();
      await _firestore.collection('medications').doc(medicationId).set({
        'medication_id': medicationId,
        'senior_id': widget.seniorId,
        'medication_name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _selectedFrequency,
        'times_per_day': _selectedTimesPerDay,
        'start_date': Timestamp.fromDate(dateTime),
        'status': 'Pending',
        'note': _noteController.text,
      });
    } else {
      // Updating an existing medicine
      medicationId = widget.medication!['medication_id'];
      await _firestore.collection('medications').doc(medicationId).update({
        'medication_name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _selectedFrequency,
        'times_per_day': _selectedTimesPerDay,
        'start_date': Timestamp.fromDate(dateTime),
        'note': _noteController.text,
      });
    }

    // ✅ Call the function to schedule notifications after saving
    _scheduleMultipleNotifications(
      medicationId,
      _nameController.text,
      _dosageController.text,
      _selectedFrequency,
      _selectedTimesPerDay,
      dateTime,
    );

    Navigator.pop(context); // Close the screen after saving
  }

  Future<void> _scheduleMultipleNotifications(
      String medicationId,
      String medicationName,
      String dosage,
      String frequency,
      String timesPerDay,
      DateTime firstDoseTime) async {
    int notificationId = medicationId.hashCode; // Unique ID for notifications

    for (int i = 0; i < _getNotificationCount(timesPerDay); i++) {
      DateTime notificationTime = firstDoseTime.add(Duration(hours: i * 6)); // Example: Spacing doses every 6 hours

      await NotificationService.scheduleNotification(
        id: notificationId + i,
        title: "Time to take your medicine",
        body: "$medicationName ($dosage) - Please take your dose", // Ensure body is passed correctly
        scheduledTime: notificationTime,
      );
    }
  }
  int _getNotificationCount(String timesPerDay) {
    switch (timesPerDay) {
      case "Once":
        return 1;
      case "Twice":
        return 2;
      case "Thrice":
        return 3;
      default:
        return 1;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.medication == null ? "Add Medicine" : "Update Medicine", // Dynamic title
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name of the medicine",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0), // Focused border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                cursorColor: Color(0xFF308A99),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: "Dosage",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      items: _frequencyOptions
                          .map((freq) => DropdownMenuItem(
                        value: freq,
                        child: Text(freq),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedFrequency = val!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Frequency",
                        labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimesPerDay,
                      items: _timesPerDayOptions
                          .map((time) => DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTimesPerDay = val!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Times Per Day",
                        labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  TextButton(
                    onPressed: _pickDate,
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF308A99),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: _selectedDate == null ? "Select Start Date" : "Selected Date: ",
                        style: TextStyle(
                          color: Color(0xFF308A99), // Label color stays teal
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          if (_selectedDate != null)
                            TextSpan(
                              text: "${_selectedDate!.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: Colors.black, // Dynamic date value in black
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: _pickTime,
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF308A99),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: _selectedTime == null ? "Select Time" : "Selected Time: ",
                        style: TextStyle(
                          color: Color(0xFF308A99), // Label color stays teal
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          if (_selectedTime != null)
                            TextSpan(
                              text: "${_selectedTime!.format(context)}",
                              style: TextStyle(
                                color: Colors.black, // Dynamic time value in black
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: "Note (optional)",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity, // Full width
                height: 60, // Height of the button
                child: OutlinedButton(
                  onPressed: _addMedication,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    widget.medication == null ? "Add Medicine" : "Update Medicine", // Dynamic text
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
