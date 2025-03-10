import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'medical_services_menu_screen.dart';

class AddMedicalInfoScreen extends StatefulWidget {
  final String seniorId;

  const AddMedicalInfoScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _AddMedicalInfoScreenState createState() => _AddMedicalInfoScreenState();
}

class _AddMedicalInfoScreenState extends State<AddMedicalInfoScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _illnessesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _bloodType;

  final List<String> _bloodTypeOptions = ["A", "B", "AB", "O"];

  Future<void> _saveMedicalInfo() async {
    try {
      await FirebaseFirestore.instance.collection('Medical_data').doc(widget.seniorId).set({
        'senior_id': widget.seniorId,
        'weight': double.tryParse(_weightController.text),
        'height': double.tryParse(_heightController.text),
        'allergies': _allergiesController.text,
        'illnesses': _illnessesController.text,
        'blood_type': _bloodType,
        'notes': _notesController.text,
        'updated_at': DateTime.now(),
      });

      // Navigate to main Medical Services screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalServicesMenuScreen(seniorId: widget.seniorId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medical info: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medical Info"),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: "Allergies",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _illnessesController,
                decoration: InputDecoration(
                  labelText: "Illnesses",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodType,
                items: _bloodTypeOptions
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodType = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Blood Type",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Notes",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMedicalInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Info",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
