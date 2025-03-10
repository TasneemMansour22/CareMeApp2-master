import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/screens/register_admin_screen.dart';
import 'package:test1/screens/register_eldery_screen.dart';
import '../models/custom_text_field.dart';
import 'ServiceProviderDashboard.dart';
import 'home_view.dart';
import 'account_type_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // Role passed from AccountTypeScreen

  const LoginScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String userId = userCredential.user!.uid;

      // Determine which collection to query based on the role
      final String collectionName =
      widget.userType == 'elderly' ? 'seniors' : 'other_users';

      // Fetch the user document from the appropriate collection
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Get user data
        final userData = userDoc.data() as Map<String, dynamic>;

        // Navigate based on role
        if (widget.userType == 'elderly' && collectionName == 'seniors') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(senior_id: userId), // Pass senior ID
            ),
          );
        } else if (widget.userType == 'service_provider' && collectionName == 'other_users') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceProviderDashboard (userId: userId), // Pass senior ID
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Service provider functionality not implemented yet.')),
          );
        } else {
          // Role mismatch or unsupported role
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role mismatch. Please Try Again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else {
        message = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void navigateToSignUpScreen() {
    if (widget.userType == 'elderly') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreenEldery()),
      );
    } else if (widget.userType == 'service_provider') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreenAdmin()),
      );
    }
  }
  Future<void> _forgotPassword() async {
    String email = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Forgot Password",
            style: TextStyle(color: Color(0xff308A99)),
          ),


          content: TextField(
            onChanged: (value) {
              email = value;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF308A99)), // Set focused border color
              ),

            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (email.isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: email.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password reset email sent! Check your inbox.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter your email.")),
                  );
                }
              },
              child: Text("Send",
                style: TextStyle(color: Color(0xff308A99)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel",
                style: TextStyle(color: Color(0xff308A99)),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Center(
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 70,
                  backgroundImage: AssetImage('assets/images/Logo.png'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hello, Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please login to access your account.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hintText: 'Enter your email',
                icon: Icons.email,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter your password',
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xff308A99)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff308A99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed:
                      navigateToSignUpScreen,

                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xff308A99)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
