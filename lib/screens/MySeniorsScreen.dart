import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SeniorDashboardScreen.dart';
import 'home_view.dart';

class MySeniorsScreen extends StatefulWidget {
  final String userId;

  const MySeniorsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MySeniorsScreenState createState() => _MySeniorsScreenState();
}

class _MySeniorsScreenState extends State<MySeniorsScreen> {
  List<Map<String, dynamic>> seniorsList = [];
  List<Map<String, dynamic>> filteredSeniors = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSeniors();
  }

  Future<void> _fetchSeniors() async {
    try {
      final seniorsSnapshot = await FirebaseFirestore.instance
          .collection('team_requests')
          .where('user_id', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'accepted') // Only assigned seniors
          .get();

      List<Map<String, dynamic>> fetchedSeniors = [];

      for (var doc in seniorsSnapshot.docs) {
        String seniorId = doc['senior_id'];

        // Fetch senior details from seniors collection
        final seniorDoc = await FirebaseFirestore.instance.collection('seniors').doc(seniorId).get();

        if (seniorDoc.exists) {
          fetchedSeniors.add({
            'senior_id': seniorId,
            'senior_name': seniorDoc.data()?['fullName'] ?? "Unknown Senior",
          });
        }
      }

      setState(() {
        seniorsList = fetchedSeniors;
        filteredSeniors = fetchedSeniors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading seniors: $e")),
      );
    }
  }

  void _filterSeniors(String query) {
    setState(() {
      filteredSeniors = seniorsList
          .where((senior) => senior['senior_name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToSeniorProfile(String seniorId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('other_users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        String userRole = userDoc.data()?['role'] ?? '';

        if (userRole.toLowerCase() == 'medical') {
          // Navigate to Senior Dashboard
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeniorDashboardScreen(seniorId: seniorId)),
          );
        } else if (userRole.toLowerCase() == 'family member') {
          // Navigate to Home Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage(senior_id: seniorId,)),
          );  // Ensure this route is defined
        } else if (userRole.toLowerCase() == 'legal & financial') {
          // Navigate to Front Screen (Replace with actual screen)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeniorDashboardScreen(seniorId: seniorId)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error determining role: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Seniors"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSeniors,
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: const TextStyle(color: Color(0xff308A99)),
                prefixIcon: const Icon(Icons.search, color: Color(0xff308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSeniors.isEmpty
                ? const Center(child: Text("No seniors assigned yet."))
                : ListView.builder(
              itemCount: filteredSeniors.length,
              itemBuilder: (context, index) {
                final senior = filteredSeniors[index];
                return ListTile(
                  title: Text(senior['senior_name']),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () => _navigateToSeniorProfile(senior['senior_id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
