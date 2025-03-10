import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_text_field.dart';
import '../models/gender_selection_ui.dart';
import 'login_screen.dart';

class RegisterScreenEldery extends StatefulWidget {
  const RegisterScreenEldery({super.key});

  @override
  _RegisterScreenElderyState createState() => _RegisterScreenElderyState();
}

class _RegisterScreenElderyState extends State<RegisterScreenEldery> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _gender;

  Future<void> _register() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      if (!isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid email address.')),
        );
        return;
      }

      // Create User with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save User Additional Data to Firestore
      await _firestore.collection('seniors').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': _countryController.text.trim(),
        'email': email,
        'dob': _dobController.text.trim(),
        'gender': _gender,


      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"
    ).hasMatch(email);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80.0,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'You have successfully registered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff308A99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(userType: 'elderly',)),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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
              const SizedBox(height: 60.0),
              Center(
                child: Column(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 70.0,
                      backgroundImage: AssetImage('assets/images/Logo.png'),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              const Text(
                'Hello',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              const Text(
                'Create a New account',
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Please register your details to access your account and enjoy shopping.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30.0),

              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Full Name',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _fullNameController,
                hintText: 'Enter your name',
                icon: Icons.person,
              ),
              const SizedBox(height: 20.0),

              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Phone Number',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _phoneController,
                hintText: 'Enter phone number',
                icon: Icons.phone,
              ),
              const SizedBox(height: 20.0),

              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'E-mail',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your E-mail',
                icon: Icons.email,
              ),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Country',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _countryController,
                hintText: 'Enter your Country',
                icon: Icons.public,
              ),
              const SizedBox(height: 20.0),

              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Password',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Enter password',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 20.0),

              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Date of Birth',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              CustomTextField(
                controller: _dobController,
                hintText: 'DD/MM/YYYY',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 20.0),

              // Replace this in your build method where GenderSelection is used.
              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  'Gender',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Male"),
                      value: "male",
                      activeColor: const Color(0xff308A99),
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Female"),
                      value: "female",
                      groupValue: _gender,
                      activeColor: const Color(0xff308A99),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                ],
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
                  child: const Text(
                    'Register',
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
