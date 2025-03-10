import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddConsultationScreen.dart';

class ConsultationsScreen extends StatefulWidget {
  final String seniorId;
  final String consultationType;

  const ConsultationsScreen({
    Key? key,
    required this.seniorId,
    required this.consultationType,
  }) : super(key: key);

  @override
  _ConsultationsScreenState createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _editConsultation(QueryDocumentSnapshot consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddConsultationScreen(
          seniorId: widget.seniorId,
          consultationType: widget.consultationType,
          existingConsultation: consultation, isServiceProvider: false, // Pass existing consultation data
        ),
      ),
    );
  }

  void _deleteConsultation(String consultationId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Consultation"),
          content: Text("Are you sure you want to delete this consultation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel",
                style: TextStyle(color: Color(0xFF308A99)),
              ),
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
      await _firestore.collection('consultations').doc(consultationId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Consultation deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.consultationType} Consultations"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('consultations')
              .where('senior_id', isEqualTo: widget.seniorId)
              .where('consultation_type', isEqualTo: widget.consultationType)
              .orderBy('updated_at', descending: true) // 🔹 Sorting applied



              .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final consultations = snapshot.data?.docs ?? [];
                final filteredConsultations = consultations.where((doc) {
                  final title = (doc['title'] ?? '').toLowerCase();
                  return title.contains(_searchQuery);
                }).toList();

                if (filteredConsultations.isEmpty) {
                  return Center(child: Text("No consultations found."));
                }

                return ListView.builder(
                  itemCount: filteredConsultations.length,
                  itemBuilder: (context, index) {
                    final consultation = filteredConsultations[index];
                    final timestamp = consultation['created_at'];
                    final dateTime = timestamp != null ? (timestamp as Timestamp).toDate() : null;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFF308A99), width: 1.5),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.assignment, color: Color(0xFF308A99)),
                        title: Text(consultation['title'] ?? 'Unknown'),
                        subtitle: dateTime != null
                            ? Text(
                          "Last Updated: ${dateTime.toLocal().toString().split(' ')[0]}",
                        )
                            : Text("No Update Date Available"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFF308A99)),
                              onPressed: () => _editConsultation(consultation),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteConsultation(consultation.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddConsultationScreen(
              seniorId: widget.seniorId,
              consultationType: widget.consultationType, isServiceProvider: false,

            ),
          ),
        ),
        backgroundColor: const Color(0xFF308A99),
        child: const Icon(Icons.add),
      ),
    );
  }
}
