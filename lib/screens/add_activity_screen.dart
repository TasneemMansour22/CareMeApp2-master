import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddActivityScreen extends StatefulWidget {
  final String seniorId;
  final Map<String, dynamic>? activity;

  const AddActivityScreen({Key? key, required this.seniorId, this.activity}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedFrequency = "Every Day"; // Default frequency
  String _selectedTimesPerDay = "Once"; // Default times per day
  final List<String> _frequencyOptions = ["Every Day", "Every Other Day", "Weekly"];
  final List<String> _timesPerDayOptions = ["Once", "Twice", "Thrice"];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // To store selected time

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _nameController.text = widget.activity!['name'] ?? '';
      _selectedFrequency = widget.activity!['frequency'] ?? 'Every Day';
      _selectedTimesPerDay = widget.activity!['times_per_day'] ?? 'Once';
      _selectedDate = (widget.activity!['start_date'] as Timestamp?)?.toDate();
      _selectedTime = _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : null;
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
              primary: Color(0xFF308A99), // Highlight color
              onPrimary: Colors.white, // Text color on primary
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
              primary: Color(0xFF308A99), // Highlight color
              onPrimary: Colors.white, // Text color on primary
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

  Future<void> _addOrUpdateActivity() async {
    if (_nameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
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

    if (widget.activity == null) {
      // Add new activity
      final activityId = Uuid().v4();
      await FirebaseFirestore.instance.collection('activities').doc(activityId).set({
        'activity_id': activityId,
        'senior_id': widget.seniorId,
        'name': _nameController.text,
        'frequency': _selectedFrequency,
        'times_per_day': _selectedTimesPerDay,
        'start_date': Timestamp.fromDate(dateTime),
      });
    } else {
      // Update existing activity
      final activityId = widget.activity!['activity_id'];
      await FirebaseFirestore.instance.collection('activities').doc(activityId).update({
        'name': _nameController.text,
        'frequency': _selectedFrequency,
        'times_per_day': _selectedTimesPerDay,
        'start_date': Timestamp.fromDate(dateTime),
      });
    }

    Navigator.pop(context); // Close the screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? "Add Activity" : "Update Activity"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Activity Name",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // Label color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    ),
                  ),
                  const SizedBox(width: 16),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                          color: Color(0xFF308A99),
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          if (_selectedDate != null)
                            TextSpan(
                              text: "${_selectedDate!.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _pickTime,
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF308A99),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: _selectedTime == null ? "Select Start Time" : "Selected Time: ",
                        style: TextStyle(
                          color: Color(0xFF308A99),
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          if (_selectedTime != null)
                            TextSpan(
                              text: "${_selectedTime!.format(context)}",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addOrUpdateActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.activity == null ? "Add Activity" : "Update Activity",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
