import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_activity_screen.dart';

class SocialActivitiesListScreen extends StatefulWidget {
  final String seniorId;

  const SocialActivitiesListScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _SocialActivitiesListScreenState createState() => _SocialActivitiesListScreenState();
}

class _SocialActivitiesListScreenState extends State<SocialActivitiesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<void> _deleteActivity(String activityId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Activity"),
          content: const Text("Are you sure you want to delete this activity?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('activities').doc(activityId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar and Add Button
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
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF308A99)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF308A99), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF308A99)),
                      ),
                    ),
                    cursorColor: const Color(0xFF308A99),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddActivityScreen(seniorId: widget.seniorId),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Add activity",
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
          // List of Activities
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('senior_id', isEqualTo: widget.seniorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final activities = snapshot.data?.docs ?? [];
                final filteredActivities = activities.where((activity) {
                  final activityName = (activity['name'] ?? '').toLowerCase();
                  return activityName.contains(_searchQuery);
                }).toList();

                if (filteredActivities.isEmpty) {
                  return const Center(child: Text("No activities found."));
                }

                return ListView.builder(
                  itemCount: filteredActivities.length,
                  itemBuilder: (context, index) {
                    final activity = filteredActivities[index].data() as Map<String, dynamic>;
                    final activityId = filteredActivities[index].id;

                    final startDate = (activity['start_date'] as Timestamp?)?.toDate();
                    final formattedDate = startDate != null
                        ? "${startDate.day}/${startDate.month}/${startDate.year}"
                        : "No Date";

                    final startTime = startDate != null
                        ? TimeOfDay.fromDateTime(startDate).format(context)
                        : "No Time";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF308A99), width: 1.5),
                      ),
                      child: ListTile(
                        title: Text(activity['name'] ?? 'Unknown'),
                        subtitle: Text("$formattedDate at $startTime"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF308A99)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddActivityScreen(
                                      seniorId: widget.seniorId,
                                      activity: activity,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteActivity(activityId),
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
