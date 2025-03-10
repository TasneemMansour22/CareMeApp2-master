import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Blood Type Enum
enum BloodType { APositive, ANegative, BPositive, BNegative, OPositive, ONegative, ABPositive, ABNegative }

extension BloodTypeExtension on BloodType {
  String get name {
    switch (this) {
      case BloodType.APositive:
        return 'A+';
      case BloodType.ANegative:
        return 'A-';
      case BloodType.BPositive:
        return 'B+';
      case BloodType.BNegative:
        return 'B-';
      case BloodType.OPositive:
        return 'O+';
      case BloodType.ONegative:
        return 'O-';
      case BloodType.ABPositive:
        return 'AB+';
      case BloodType.ABNegative:
        return 'AB-';
      default:
        return '';
    }
  }

  static BloodType fromString(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return BloodType.APositive;
      case 'A-':
        return BloodType.ANegative;
      case 'B+':
        return BloodType.BPositive;
      case 'B-':
        return BloodType.BNegative;
      case 'O+':
        return BloodType.OPositive;
      case 'O-':
        return BloodType.ONegative;
      case 'AB+':
        return BloodType.ABPositive;
      case 'AB-':
        return BloodType.ABNegative;
      default:
        throw Exception('Invalid blood type');
    }
  }
}

class MedicalInfoScreen extends StatefulWidget {
  final String seniorId;
  final bool isReadOnly; // ✅ New parameter to control edit mode

  const MedicalInfoScreen({Key? key, required this.seniorId, required this.isReadOnly}) : super(key: key);

  @override
  _MedicalInfoScreenState createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _allergiesController = TextEditingController();
  TextEditingController _illnessesController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  BloodType? _selectedBloodType;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  Future<void> _fetchMedicalData() async {
    try {
      final doc = await _firestore.collection('Medical_data').doc(widget.seniorId).get();

      if (doc.exists) {
        final data = doc.data();
        _heightController.text = data?['height']?.toString() ?? '';
        _weightController.text = data?['weight']?.toString() ?? '';
        _allergiesController.text = data?['allergies'] ?? '';
        _illnessesController.text = data?['illnesses'] ?? '';
        _notesController.text = data?['notes'] ?? '';

        // Convert the stored blood type string back to the enum
        _selectedBloodType = BloodTypeExtension.fromString(data?['blood_type'] ?? '');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedicalData() async {
    if (widget.isReadOnly) return; // ✅ Prevent saving if read-only

    try {
      await _firestore.collection('Medical_data').doc(widget.seniorId).set({
        'blood_type': _selectedBloodType?.name, // Save blood type as string
        'height': int.tryParse(_heightController.text),
        'weight': int.tryParse(_weightController.text),
        'allergies': _allergiesController.text,
        'illnesses': _illnessesController.text,
        'notes': _notesController.text,
        'senior_id': widget.seniorId,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medical information updated successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBloodTypeDropdown(),
            _buildTextField('Height (cm)', _heightController, keyboardType: TextInputType.number),
            _buildTextField('Weight (kg)', _weightController, keyboardType: TextInputType.number),
            _buildTextField('Allergies', _allergiesController),
            _buildTextField('Illnesses', _illnessesController),
            _buildTextField('Notes', _notesController, maxLines: 3),
            const SizedBox(height: 20),
            if (!widget.isReadOnly) // ✅ Only show save button if editable
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedicalData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF308A99), // App color
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Information',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<BloodType>(
        value: _selectedBloodType,
        onChanged: widget.isReadOnly
            ? null
            : (BloodType? newValue) {
          setState(() {
            _selectedBloodType = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Blood Type',
          labelStyle: const TextStyle(color: Color(0xFF308A99)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99)),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: BloodType.values.map<DropdownMenuItem<BloodType>>((BloodType value) {
          return DropdownMenuItem<BloodType>(
            value: value,
            child: Text(value.name),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: !widget.isReadOnly, // ✅ Disable editing if read-only
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF308A99)), // App color
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 2), // App color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99), width: 1.5), // App color
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF308A99)), // App color
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
