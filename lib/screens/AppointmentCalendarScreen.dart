import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  final String seniorId; // Pass seniorId to link appointments to a senior

  const AppointmentCalendarScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _AppointmentCalendarScreenState createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _eventController = TextEditingController();

  // Fetch appointments from Firebase
  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('senior_id', isEqualTo: widget.seniorId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'event': data['event'],
        'date': (data['date'] as Timestamp).toDate(),
      };
    }).toList();
  }

  Future<void> _addEvent(String event) async {
    await FirebaseFirestore.instance.collection('appointments').add({
      'senior_id': widget.seniorId,
      'event': event,
      'date': _selectedDay,
    });
    setState(() {});
    Navigator.pop(context); // Close the dialog
    _eventController.clear();
  }

  Future<void> _deleteEvent(String id) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).delete();
    setState(() {});
  }

  Future<void> _editEvent(String id, String updatedEvent) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'event': updatedEvent});
    setState(() {});
    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Calendar"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month, // Lock calendar to month view
            availableCalendarFormats: const {CalendarFormat.month: 'Month'}, // Disable the FormatButton
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            daysOfWeekHeight: 40, // 🔥 Increase this value (default is ~16)
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 16), // 🔥 Increase font size if needed

            ),
            calendarStyle: const CalendarStyle(

              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF308A99),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events for this date."));
                }

                final events = snapshot.data!.where((event) {
                  return isSameDay(event['date'], _selectedDay);
                }).toList();

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event['event']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _eventController.text = event['event'];
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Edit Event",
                                    style: TextStyle(color:Color(0xFF308A99),),
                                  ),
                                  content: TextField(
                                    controller: _eventController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter updated event details",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel",
                                        style: TextStyle(color: Colors.white,

                                        ),
                                      ),
                                      style:TextButton.styleFrom(backgroundColor:Color(0xFF308A99), ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _editEvent(
                                          event['id'], _eventController.text),
                                      child: const Text("Save",
                                        style: TextStyle(color: Colors.white,

                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF308A99),),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEvent(event['id']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              title: const Text(
                "Add Event",
                style: TextStyle(
                  color: Color(0xFF308A99), // App color
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
                controller: _eventController,
                decoration: InputDecoration(
                  hintText: "Enter event details",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF308A99)), // App color underline
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF308A99), // App color for text
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addEvent(_eventController.text); // Call the event-adding function
                    Navigator.pop(context); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF308A99), // App color for button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white), // White text for contrast
                  ),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFF308A99),
        child: const Icon(Icons.add),
      ),
    );
  }
}
