import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddConsultationScreen extends StatefulWidget {
  final String seniorId;
  final String consultationType;
  final QueryDocumentSnapshot? existingConsultation;
  final bool isServiceProvider; // Determines if it's a service provider
  final String? consultantId;
  AddConsultationScreen({
    required this.seniorId,
    required this.consultationType,
    this.existingConsultation,
    required this.isServiceProvider,
    this.consultantId,
  });

  @override
  _AddConsultationScreenState createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? attachedFileUrl;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String consultantName = "Waiting...";


  @override
  void initState() {
    super.initState();

    if (widget.existingConsultation != null) {
      var consultationData = widget.existingConsultation!.data() as Map<String, dynamic>?;

      _titleController.text = consultationData?['title'] ?? '';
      _detailsController.text = consultationData?['details'] ?? '';
      attachedFileUrl = consultationData?['attached_document'] ?? '';
      _replyController.text = consultationData?['consultation_reply'] ?? '';

      // Fetch the consultant who replied (not the current one)
      if (consultationData?['consultation_replied_by'] != null) {
        getConsultantName(consultationData!['consultation_replied_by']).then((name) {
          setState(() {
            consultantName = name;
          });
        });
      } else {
        consultantName = "Waiting...";
      }
    }
  }

  Future<String> getConsultantName(String consultantId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('other_users')
          .doc(consultantId)
          .get();

      if (doc.exists) {
        return doc['fullName'] ?? "Waiting..."; // Fetching name
      } else {
        return "Waiting...";
      }
    } catch (e) {
      return "Error Fetching Name";
    }
  }

  Future<void> _submitReply() async {
    if (!widget.isServiceProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only consultants can reply to this consultation.")),
      );
      return;
    }

    if (_replyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reply cannot be empty")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.existingConsultation!.id)
          .update({
        'consultation_reply': _replyController.text,
        'consultation_replied_by': currentUser?.uid, // Store consultant's ID
        'updated_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reply updated successfully")),
      );

      setState(() {});  // Refresh UI after update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }



  Widget _buildReplySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Consultant's Reply :$consultantName", style: TextStyle(color: Color(0xFF308A99), fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: _replyController,
          readOnly: !widget.isServiceProvider,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (widget.isServiceProvider)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReply,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF308A99),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Submit Reply", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ],
    );

  }

  Future<void> _attachDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance.ref().child('consultation_documents/${file.name}');
      final uploadTask = await ref.putFile(File(file.path!));
      final fileUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        attachedFileUrl = fileUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document attached successfully")));
    }
  }

  Future<void> _saveOrUpdateConsultation() async {
    if (_titleController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and details are required")),
      );
      return;
    }

    try {
      if (widget.existingConsultation == null) {
        // Save New Consultation
        await FirebaseFirestore.instance.collection('consultations').add({
          'senior_id': widget.seniorId,
          'consultation_type': widget.consultationType,
          'title': _titleController.text,
          'details': _detailsController.text,
          'consultant_id': widget.consultantId ?? '', // ✅ Save only if consultant
          'attached_document': attachedFileUrl ?? '',
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consultation saved successfully")),
        );
      } else {
        // Update Existing Consultation
        await FirebaseFirestore.instance
            .collection('consultations')
            .doc(widget.existingConsultation!.id)
            .update({
          'title': _titleController.text,
          'details': _detailsController.text,
          'attached_document': attachedFileUrl ?? '',
          'updated_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consultation updated successfully")),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.existingConsultation == null ? "Add Consultation" : "Update Consultation",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                readOnly: widget.isServiceProvider,
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // App color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0), // Focus color
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                readOnly: widget.isServiceProvider,
                decoration: InputDecoration(
                  labelText: "Details",
                  labelStyle: TextStyle(color: Color(0xFF308A99)), // App color
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0), // Focus color
                  ),
                ),
              ),

              const SizedBox(height: 16),
              if (!widget.isServiceProvider)
                ElevatedButton(
                  onPressed: _attachDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF308A99)),
                  child: const Text("Attach Document",
                      style: TextStyle(color: Colors.white)
                  ),
                ),
              const SizedBox(height: 16),
              if (!widget.isServiceProvider)
                SizedBox(
                    width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF308A99)),
                    onPressed: _saveOrUpdateConsultation,
                    child: Text(widget.existingConsultation == null ? "Save Consultation" : "Update Consultation", style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 16),
              _buildReplySection(),
            ],
          ),
        ),
      ),
    );
  }
}
