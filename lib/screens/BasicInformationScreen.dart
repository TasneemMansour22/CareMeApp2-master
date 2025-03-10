import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BasicInformationScreen extends StatefulWidget {
  final String seniorId;
  final bool isSenior;

  const BasicInformationScreen({Key? key, required this.seniorId, required this.isSenior}) : super(key: key);

  @override
  _BasicInformationScreenState createState() => _BasicInformationScreenState();
}

class _BasicInformationScreenState extends State<BasicInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String _gender = '';
  DateTime? _dateOfBirth;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('seniors').doc(widget.seniorId).get();
      if (doc.exists) {
        print("Fetched data: ${doc.data()}"); // Debugging: Print all fetched data

        setState(() {
          _nameController.text = doc['fullName'] ?? '';
          _emailController.text = doc['email'] ?? '';
          _phoneController.text = doc['phone'] ?? '';
          _countryController.text = doc['country'] ?? ''; // Ensure country is fetched
          _gender = doc['gender'] ?? ''; // Ensure gender is fetched
          _dateOfBirth = (doc.data()!.containsKey('date_of_birth') && doc['date_of_birth'] != null)
              ? (doc['date_of_birth'] as Timestamp).toDate()
              : null; // Ensure date is fetched
          isLoading = false;
        });
      } else {
        print("Document does not exist");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('seniors').doc(widget.seniorId).update({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'country': _countryController.text, // Ensure country is included
        'gender': _gender, // Ensure gender is included
        'date_of_birth': _dateOfBirth != null ? Timestamp.fromDate(_dateOfBirth!) : null, // Ensure date is included
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Information updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving changes: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSenior ? "Registered Information" : "Basic Information"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField("Full Name", _nameController, widget.isSenior),
              _buildInputField("Email", _emailController, widget.isSenior),
              _buildInputField("Phone", _phoneController, widget.isSenior),
              _buildInputField("Country", _countryController, widget.isSenior),
              _buildDropdownField("Gender", ["Male", "Female"], widget.isSenior),
              _buildDatePicker("Date of Birth", widget.isSenior),
              if (widget.isSenior)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308A99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            readOnly: !isEditable,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: (_gender.isNotEmpty && ["Male", "Female"].contains(_gender)) ? _gender : null,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: isEditable ? (newValue) => setState(() => _gender = newValue!) : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDatePicker(String label, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: isEditable
                ? () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF308A99),  // Changes header & buttons color
                        onPrimary: Colors.white,      // Text color on selected button
                        onSurface: Colors.black,      // Default text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF308A99), // Changes "OK" & "Cancel" buttons color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },

              );
              if (pickedDate != null) {
                setState(() {
                  _dateOfBirth = pickedDate;
                });
              }
            }
                : null,
            child: Text(_dateOfBirth != null ? _dateOfBirth!.toLocal().toString().split(' ')[0] : "Select Date",style: TextStyle(color:Color(0xFF308A99) ),),
          ),
        ],
      ),
    );
  }
}
