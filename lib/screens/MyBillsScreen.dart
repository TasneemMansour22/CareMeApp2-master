import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_bill_screen.dart';

class MyBillsScreen extends StatefulWidget {
  final String seniorId;

  const MyBillsScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _MyBillsScreenState createState() => _MyBillsScreenState();
}

class _MyBillsScreenState extends State<MyBillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<List<Map<String, dynamic>>> _fetchBills() async {
    final billsSnapshot = await FirebaseFirestore.instance
        .collection('Bills')
        .where('senior_id', isEqualTo: widget.seniorId)
        .get();

    return billsSnapshot.docs.map((doc) {
      final bill = doc.data();
      bill['id'] = doc.id;
      bill['status'] = bill.containsKey('status') ? bill['status'] : 'Unpaid'; // ✅ Include status
      return bill;
    }).toList();
  }

// Add a sorting dropdown
  String _selectedSortOption = 'Date'; // Default sorting option

  void _sortBills(List<Map<String, dynamic>> bills) {
    if (_selectedSortOption == 'Date') {
      bills.sort((a, b) {
        final dateA = (a['due_date'] as Timestamp).toDate();
        final dateB = (b['due_date'] as Timestamp).toDate();
        return dateA.compareTo(dateB);
      });
    } else if (_selectedSortOption == 'Amount') {
      bills.sort((a, b) {
        final amountA = a['amount_due'] as double;
        final amountB = b['amount_due'] as double;
        return amountA.compareTo(amountB);
      });
    }
  }

  Future<void> _deleteBill(String billId) async {
    try {
      await FirebaseFirestore.instance.collection('Bills').doc(billId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bill deleted successfully!")),
      );
      setState(() {}); // Refresh the list after deleting
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting bill: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bills'),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
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
            // Sort Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedSortOption,
                  items: const [
                    DropdownMenuItem(
                      value: 'Date',
                      child: Text('Date'),
                    ),
                    DropdownMenuItem(
                      value: 'Amount',
                      child: Text('Amount'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSortOption = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bills List Section
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchBills(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final bills = snapshot.data ?? [];
                  final filteredBills = bills.where((bill) {
                    final type = (bill['bill_type'] ?? '').toLowerCase();
                    return type.contains(_searchQuery);
                  }).toList();

                  _sortBills(filteredBills); // Apply sorting based on the selected option


                  if (filteredBills.isEmpty) {
                    return const Center(child: Text('No bills found'));
                  }

                  return ListView.builder(
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(bill['bill_type'],style: TextStyle(color: Color(0xFF308A99),fontWeight: FontWeight.bold,),),
                          subtitle: Text(
                            'Due Date: ${(bill['due_date'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}\n'
                                'Amount: \$${bill['amount_due']}\n'
                                'Status: ${bill['status']}', // ✅ Show status
                            style: TextStyle(
                              color: bill['status'] == 'Paid' ? Colors.green[300] : Colors.red[300], // ✅ Green for paid, red for unpaid
                             // fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  bill['status'] == 'Paid' ? Icons.check_circle : Icons.radio_button_unchecked, // ✅ Toggle icon
                                  color: bill['status'] == 'Paid' ? Colors.green : Colors.grey,
                                ),
                                onPressed: () async {
                                  // Toggle status between Paid/Unpaid
                                  String newStatus = bill['status'] == 'Paid' ? 'Unpaid' : 'Paid';
                                  await FirebaseFirestore.instance.collection('Bills').doc(bill['id']).update({
                                    'status': newStatus,
                                  });
                                  setState(() {}); // Refresh UI
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF308A99)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddBillScreen(
                                        seniorId: widget.seniorId,
                                        billType: bill['bill_type'],
                                        bill: bill,
                                      ),
                                    ),
                                  ).then((_) => setState(() {})); // Refresh after editing
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBill(bill['id']),
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
      ),
    );
  }
}
//