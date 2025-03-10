import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AddConsultationScreen.dart';

class MyConsultationsScreen extends StatefulWidget {
  final String? seniorId;

  const MyConsultationsScreen({Key? key, this.seniorId}) : super(key: key);

  @override
  _MyConsultationsScreenState createState() => _MyConsultationsScreenState();
}

class _MyConsultationsScreenState extends State<MyConsultationsScreen> {
  String searchQuery = "";
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String? userRole; // Medical, Legal, etc.
  List<String> assignedSeniorIds = [];
  // Seniors assigned to this service provider

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndAssignedSeniors();
  }

  Future<void> _fetchUserRoleAndAssignedSeniors() async {
    try {
      // 🔹 Fetch user role (Medical, Legal, etc.)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('other_users') // Adjust this if needed
          .doc(userId)
          .get();

      setState(() {
        userRole = userDoc['role']; // Ensure this field exists
      });

      // 🔹 Fetch assigned seniors from "team_requests" where status is "accepted"
      QuerySnapshot teamRequests = await FirebaseFirestore.instance
          .collection('team_requests')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      setState(() {
        assignedSeniorIds = teamRequests.docs.map((doc) => doc['senior_id'].toString()).toList();
      });
    } catch (e) {
      print("Error fetching role or assigned seniors: $e");
    }
  }

  Stream<QuerySnapshot> _fetchConsultations() {
    if (userRole == null) {
      return const Stream.empty();
    }

    Query baseQuery = FirebaseFirestore.instance
        .collection('consultations')
        .where('consultation_type', isEqualTo: userRole) // Filter by role
        .orderBy('updated_at', descending: true); // Sort by latest update

    if (widget.seniorId != null) {
      // 🔹 If seniorId is provided, filter by that specific senior
      baseQuery = baseQuery.where('senior_id', isEqualTo: widget.seniorId);
    } else if (assignedSeniorIds.isNotEmpty) {
      // 🔹 Otherwise, filter by all assigned seniors
      baseQuery = baseQuery.where('senior_id', whereIn: assignedSeniorIds);
    } else {
      return const Stream.empty();
    }

    return baseQuery.snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search consultations...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // 📜 Consultation List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchConsultations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No consultations found."));
                }

                // 🔹 Filter search results
                var consultations = snapshot.data!.docs.where((doc) {
                  var title = doc['title'].toString().toLowerCase();
                  return title.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: consultations.length,
                  itemBuilder: (context, index) {
                    var consultation = consultations[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('seniors')
                          .doc(consultation['senior_id'])
                          .get(),
                      builder: (context, seniorSnapshot) {
                        String seniorName = "Unknown";

                        if (seniorSnapshot.hasData && seniorSnapshot.data!.exists) {
                          seniorName = seniorSnapshot.data!['fullName'] ?? "Unknown";
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            title: Text(consultation['title'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("From: $seniorName"),
                            trailing: Text(
                              _formatTimestamp(consultation['updated_at']),
                              style: TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddConsultationScreen(
                                    consultationType: consultation['consultation_type'], // Pass correct type
                                    consultantId: userId,
                                    seniorId: consultation['senior_id'], // Pass senior ID
                                    existingConsultation: consultation, // Pass the full document for details
                                    isServiceProvider: true, // Set as service provider
                                  ),
                                ),
                              );
                            },

                          ),
                        );
                      },
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

  // 📆 Format Timestamp for UI
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}";
  }
}
