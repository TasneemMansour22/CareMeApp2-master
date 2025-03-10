import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  final String seniorId;
  final bool isSenior;  // New parameter

  MedicationListScreen({required this.seniorId, required this.isSenior});

  @override
  _MedicationListScreenState createState() => _MedicationListScreenState();
}


class _MedicationListScreenState extends State<MedicationListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _editMedication(Map<String, dynamic> medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(
          seniorId: widget.seniorId, // Use passed seniorId
          medication: medication,
        ),
      ),
    );
  }

  void _deleteMedication(String medicationId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Medication"),
          content: Text("Are you sure you want to delete this medication?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await _firestore.collection('medications').doc(medicationId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medication deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication Reminder"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF308A99)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF308A99)),
                      ),
                    ),
                    cursorColor: Color(0xFF308A99),
                  ),
                ),
                SizedBox(width: 10),
                if (widget.isSenior)
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedicationScreen(
                          seniorId: widget.seniorId,
                          medication: null,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: const Text(
                        "Add Medicine",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308A99),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),


              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('medications')
                  .where('senior_id', isEqualTo: widget.seniorId) // Use passed seniorId
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final medications = snapshot.data?.docs ?? [];

                final filteredMedications = medications.where((med) {
                  final medicationName = (med['medication_name'] ?? '').toLowerCase();
                  return medicationName.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = filteredMedications[index].data() as Map<String, dynamic>;
                    final timestamp = medication['start_date'];
                    final dateTime = timestamp != null ? (timestamp as Timestamp).toDate() : null;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFF308A99), width: 1.5),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.medication, color: Color(0xFF308A99)),
                        title: Text(medication['medication_name'] ?? 'Unknown'),
                        subtitle: dateTime != null
                            ? Text(
                          "Dosage: ${medication['dosage']}\nNext Dose: ${dateTime.toLocal().toString().split(' ')[0]} at ${TimeOfDay.fromDateTime(dateTime).format(context)}",
                        )
                            : Text("Dosage: ${medication['dosage']}\nNext Dose: Not Set"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFF308A99)),
                              onPressed: () => _editMedication(medication),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMedication(medication['medication_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
