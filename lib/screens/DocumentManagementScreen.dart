import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddDocumentScreen.dart';

class DocumentManagementScreen extends StatefulWidget {
  final String seniorId;

  const DocumentManagementScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _DocumentManagementScreenState createState() => _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<void> _addDocument() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentScreen(seniorId: widget.seniorId),
      ),
    );
  }

  Future<void> _editDocument(String docId, String currentName, String currentDescription) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController descriptionController = TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Document"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",labelStyle: TextStyle(color: Color(0xFF308A99)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0),
                  ),
                ),
                cursorColor: Color(0xFF308A99),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",labelStyle: TextStyle(color: Color(0xFF308A99)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0),
                  ),
                ),
                cursorColor: Color(0xFF308A99),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Color(0xFF308A99))),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('documents').doc(docId).update({
                  'name': nameController.text,
                  'description': descriptionController.text,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF308A99)),
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDocument(String docId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Document"),
          content: Text("Are you sure you want to delete this document?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('documents').doc(docId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        title: const Text("Document Management"),
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
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addDocument,
                  child: Text("Add document",style: TextStyle(  color: Colors.white,),),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF308A99)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('senior_id', isEqualTo: widget.seniorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final documents = snapshot.data?.docs ?? [];
                final filteredDocuments = documents.where((document) {
                  final docName = (document['name'] ?? '').toLowerCase();
                  return docName.contains(_searchQuery);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return Center(child: Text("No documents found."));
                }

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    final docData = document.data() as Map<String, dynamic>;
                    final docId = document.id;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(Icons.description, color: Color(0xFF308A99)),
                        title: Text(docData['name'] ?? 'Unknown Document'),
                        subtitle: Text(docData['description'] ?? 'No Description'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editDocument(docId, docData['name'], docData['description']);
                            } else if (value == 'delete') {
                              _deleteDocument(docId);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
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
