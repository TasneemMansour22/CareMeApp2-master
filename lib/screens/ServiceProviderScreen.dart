import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ServiceProviderProfileScreen.dart';

class ServiceProviderScreen extends StatefulWidget {
  final String seniorId; // Senior ID to link the booking.

  const ServiceProviderScreen({Key? key, required this.seniorId, required this.serviceType}) : super(key: key);

  final String serviceType; // Medical, Legal, or Financial


  @override
  _ServiceProviderScreenState createState() => _ServiceProviderScreenState();
}

class _ServiceProviderScreenState extends State<ServiceProviderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentProviderId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentProvider();
  }
  Future<void> _cancelOrRemoveProvider(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('team_requests')
          .where('senior_id', isEqualTo: widget.seniorId)
          .where('user_id', isEqualTo: providerId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await _firestore.collection('team_requests').doc(snapshot.docs.first.id).delete();
        setState(() {
          _fetchCurrentProvider(); // Refresh the provider list
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _fetchCurrentProvider() async {
    final snapshot = await _firestore
        .collection('team_requests')
        .where('senior_id', isEqualTo: widget.seniorId)
        .where('status', isEqualTo: 'accepted')
        .where('service_type', isEqualTo: widget.serviceType) // Filter by service type
        .get();


    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentProviderId = snapshot.docs.first['user_id'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedicalProviders() async {
    final providersSnapshot = await _firestore
        .collection('other_users')
        .where('role', isEqualTo: widget.serviceType)
        .get();

    final requestsSnapshot = await _firestore
        .collection('team_requests')
        .where('senior_id', isEqualTo: widget.seniorId)
        .get();

    final requestedProviders = {
      for (var doc in requestsSnapshot.docs) doc['user_id']: doc['status']
    };

    return providersSnapshot.docs
        .where((doc) =>
    widget.serviceType != "Family member" || // Keep all other service types
        (requestedProviders[doc.id] == "accepted")) // Keep only accepted family members
        .map((doc) {
      final provider = doc.data();
      provider['user_id'] = doc.id;
      provider['isRequested'] = requestedProviders.containsKey(doc.id);
      provider['requestStatus'] = requestedProviders[doc.id];
      return provider;
    }).toList();
  }






  void _bookProvider(String providerId, String providerName) async {
    try {
      final existingRequestSnapshot = await _firestore
          .collection('team_requests')
          .where('senior_id', isEqualTo: widget.seniorId)
          .where('status', whereIn: ['requested', 'accepted'])
          .where('service_type', isEqualTo: widget.serviceType)
          .get();

      if (existingRequestSnapshot.docs.isNotEmpty) {
        final existingProviderName = existingRequestSnapshot.docs.first['user_name'];
        _showWarningDialog(
            'Request Denied',
            'You are already in contact with $existingProviderName. '
                'Cancel the current request to choose another provider.');
        return;
      }

      await _firestore.collection('team_requests').add({
        'senior_id': widget.seniorId,
        'user_id': providerId,

        'service_type': widget.serviceType,
        'status': 'requested',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have requested $providerName successfully!')),
      );

      await _fetchCurrentProvider(); // Wait for it to finish

      setState(() {}); // Ensure UI refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking provider: $e')),
      );
    }
  }


  void _showWarningDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                style: TextStyle(color:Color(0xFF308A99), ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.serviceType} Service Providers"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMedicalProviders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final providers = snapshot.data ?? [];

                  final filteredProviders = providers.where((provider) {
                    final name = (provider['fullName'] ?? '').toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

// Sort so the "Requested" provider appears first
                  filteredProviders.sort((a, b) {
                    if (a['isRequested'] == true && b['isRequested'] != true) return -1;
                    if (b['isRequested'] == true && a['isRequested'] != true) return 1;
                    return 0; // Maintain the default order otherwise
                  });


                  if (filteredProviders.isEmpty) {
                    return const Center(
                      child: Text("No Service Providers Found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];
                      final isRequested = provider['isRequested'] ?? false;
                      final requestStatus = provider['requestStatus'] ?? null;

                      return Column(
                        children: [
                          if (index == 0 && requestStatus == 'requested')
                            const Divider(thickness: 1.5, color: Colors.grey),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child:
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceProviderProfileScreen(
                                      userId: provider['user_id'],
                                      isReadOnly: true,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () async {
                                if (provider['isRequested']) {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          provider['requestStatus'] == 'accepted'
                                              ? "Remove Service Provider"
                                              : "Cancel Request",
                                        ),
                                        content: Text(
                                          provider['requestStatus'] == 'accepted'
                                              ? "Are you sure you want to remove this service provider?"
                                              : "Are you sure you want to cancel this request?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text("No", style: TextStyle(color: Colors.red)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                              await _cancelOrRemoveProvider(provider['user_id']);
                                            },
                                            child: Text("Yes", style: TextStyle(color: Color(0xFF308A99))),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(provider['requestStatus'] == 'accepted'
                                            ? "Provider removed successfully"
                                            : "Request canceled successfully"),
                                      ),
                                    );
                                  }
                                }
                              },
                              leading: CircleAvatar(
                                backgroundImage: provider['profile_picture'] != null
                                    ? NetworkImage(provider['profile_picture'])
                                    : null,
                                child: provider['profile_picture'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(provider['fullName'] ?? 'Unknown'),
                              trailing: ElevatedButton(
                                onPressed: provider['isRequested']
                                    ? null // Disable the button for requested/accepted states
                                    : () => _bookProvider(provider['user_id'], provider['fullName']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: provider['isRequested']
                                      ? (provider['requestStatus'] == 'accepted'
                                      ? Colors.green // Green for "Accepted"
                                      : Colors.grey) // Grey for "Requested"
                                      : const Color(0xFF308A99), // Teal for "Request Now"
                                ),
                                child: Text(
                                  provider['isRequested']
                                      ? (provider['requestStatus'] == 'accepted' ? "Accepted" : "Requested")
                                      : "Request Now",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),


                          ),
                          if (index == 0 && requestStatus == 'requested')
                            const Divider(thickness: 1.5, color: Colors.grey),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
