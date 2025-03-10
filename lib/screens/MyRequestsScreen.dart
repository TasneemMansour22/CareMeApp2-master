import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRequestsScreen extends StatefulWidget {
  final String userId; // Logged-in service provider ID

  const MyRequestsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<Map<String, dynamic>> requestsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('team_requests')
          .where('user_id', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'requested')
          .get();

      List<Map<String, dynamic>> fetchedRequests = [];

      for (var doc in requestsSnapshot.docs) {
        String seniorId = doc['senior_id'];

        final seniorDoc =
        await FirebaseFirestore.instance.collection('seniors').doc(seniorId).get();

        if (seniorDoc.exists) {
          fetchedRequests.add({
            'request_id': doc.id,
            'senior_id': seniorId,
            'senior_name': seniorDoc['fullName'] ?? "Unknown Senior",
          });
        }
      }

      setState(() {
        requestsList = fetchedRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading requests: $e")),
      );
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('team_requests').doc(requestId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully!")),
      );

      _fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requestsList.isEmpty
          ? const Center(child: Text("No new requests."))
          : ListView.builder(
        itemCount: requestsList.length,
        itemBuilder: (context, index) {
          final request = requestsList[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(request['senior_name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () =>
                        _updateRequestStatus(request['request_id'], "accepted"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                    child: const Text("Accept"),
                  ),
                  TextButton(
                    onPressed: () =>
                        _updateRequestStatus(request['request_id'], "rejected"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Reject"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
