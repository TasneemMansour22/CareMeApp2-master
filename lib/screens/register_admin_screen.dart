import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import '../models/custom_text_field.dart';

class RegisterScreenAdmin extends StatefulWidget {
  const RegisterScreenAdmin({super.key});

  @override
  State<RegisterScreenAdmin> createState() => _RegisterScreenAdminState();
}

class _RegisterScreenAdminState extends State<RegisterScreenAdmin> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _studyController = TextEditingController();
  String? _selectedRole; // Selected role

  final List<String> _roles = [
    'Medical',
    'Legal & Financial',
    'Family member'
  ]; // Enum values

  Future<void> _register() async {
    try {
      // Validate role selection
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role.')),
        );
        return;
      }

      // Create User with Email and Password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save Additional Data to Firestore
      await _firestore.collection('other_users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _countryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'study_field': _studyController.text.trim(),
        'role': _selectedRole, // Save selected role

      });

      // Show Success Dialog
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 20),
              const Text('Success', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('You have successfully registered your account.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen(userType: 'service_provider',)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80.0),
              const Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 70.0,
                      backgroundImage: AssetImage('assets/images/Logo.png'),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              const Text('Hello', style: TextStyle(fontSize: 24)),
              const Text('Create a New account', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30.0),

              const _FieldLabel(label: 'Full Name'),
              CustomTextField(controller: _fullNameController, hintText: 'Enter your name', icon: Icons.person),

              const SizedBox(height: 20.0),

              const _FieldLabel(label: 'Phone Number'),
              CustomTextField(controller: _phoneController, hintText: 'Enter phone number', icon: Icons.phone),

              const SizedBox(height: 20.0),

              const _FieldLabel(label: 'E-mail'),
              CustomTextField(controller: _emailController, hintText: 'Enter your E-mail', icon: Icons.email),
              const _FieldLabel(label: 'Country'),
              CustomTextField(controller: _countryController, hintText: 'Enter your Country', icon: Icons.public),
              const _FieldLabel(label: 'Study Field'),
              CustomTextField(controller: _studyController, hintText: 'Enter your Country', icon: Icons.school),


              const SizedBox(height: 20.0),

              const _FieldLabel(label: 'Password'),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Enter password',
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 20.0),

              const _FieldLabel(label: 'Role'),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F4FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),

              const SizedBox(height: 20.0),

              const _FieldLabel(label: 'Description'),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F4FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),

              const SizedBox(height: 30.0),

              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff308A99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Register', style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(width: 8.0),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
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

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
