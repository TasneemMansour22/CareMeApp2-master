import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  final String userId;
  final bool isReadOnly; // Determines if profile is editable

  const ServiceProviderProfileScreen({Key? key, required this.userId, required this.isReadOnly}) : super(key: key);

  @override
  _ServiceProviderProfileScreenState createState() => _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState extends State<ServiceProviderProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false; // Controls edit mode only for service providers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController studyFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('other_users').doc(widget.userId).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          nameController.text = userData!["fullName"] ?? "";
          phoneController.text = userData!["phone"] ?? "";
          countryController.text = userData!["country"] ?? "";
          descriptionController.text = userData!["description"] ?? "";
          studyFieldController.text = userData!["study_field"] ?? "";
          isLoading = false;

          // Get the user role and debug print it
          String userRole = userData!["role"] ?? "";
          print("Fetched User Role: $userRole");  // Debugging step

          // Ensure "Family Member" is checked properly (case-sensitive fix)
          if (!widget.isReadOnly && userRole.trim().toLowerCase() != "family member" &&
              (studyFieldController.text.isEmpty || descriptionController.text.isEmpty)) {
            isEditing = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Filling out your Study Field and Description helps seniors choose you!"),
                  backgroundColor: Colors.orange,
                ),
              );
            });
          }
        });
      } else {
        print("User document does not exist");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user data: $e"); // Debugging error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }



  Future<void> _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('other_users').doc(widget.userId).update({
        "fullName": nameController.text,
        "phone": phoneController.text,
        "country": countryController.text,
        "description": descriptionController.text,
        "study_field": studyFieldController.text,
      });
      setState(() {
        isEditing = false; // ✅ Make profile read-only again after saving
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xff308A99),
        foregroundColor: Colors.white,
        actions: widget.isReadOnly
            ? [] // ✅ Seniors cannot edit, so hide the button
            : [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              }
              setState(() {
                isEditing = !isEditing; // Toggle edit mode
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("User not found"))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _buildEditableField("Full Name", nameController, isEditable: false), // Full name never changes
              Text(
                "Role: ${userData!["role"]}",
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildEditableField("Phone", phoneController, icon: Icons.phone, isEditable: isEditing),
              _buildEditableField("Email", TextEditingController(text: userData!["email"]), isEditable: false, icon: Icons.email),
              _buildEditableField("Country", countryController, icon: Icons.public, isEditable: isEditing),
              _buildEditableField("Study Field", studyFieldController, icon: Icons.school, isEditable: isEditing),
              _buildEditableField("Description", descriptionController, icon: Icons.info, isEditable: isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isEditable = true, IconData? icon, Color color = const Color(0xff308A99)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.teal) : null,
        title: isEditable
            ? TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: color),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
          ),
        )
            : Text(controller.text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
