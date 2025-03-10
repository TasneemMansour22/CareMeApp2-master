import 'package:flutter/material.dart';
import 'package:test1/screens/login_screen.dart';
import 'package:test1/screens/register_admin_screen.dart';
import 'package:test1/screens/register_eldery_screen.dart';

import 'account_type_screen.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String _selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 140,
                child: Image.asset('assets/images/Logo.png'),
              ),
              const SizedBox(height: 24),
              const Text(
                "Let’s get started!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Login to enjoy the features we’ve provided.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = '';
                  });
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountTypeScreen(),
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == ''
                      ? Color(0xff308A99)
                      : Colors.white,
                  minimumSize: const Size(300, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xff308A99),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: _selectedRole == ''
                        ? Colors.white
                        : Color(0xff308A99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'care_provider';
                  });
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreenAdmin(),
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == 'care_provider'
                      ? Color(0xff308A99)
                      : Colors.white,
                  minimumSize: const Size(300, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xff308A99),
                  ),
                ),
                child: Text(
                  "Sign Up as a care provider",
                  style: TextStyle(
                    fontSize: 18,
                    color: _selectedRole == 'care_provider'
                        ? Colors.white
                        : Color(0xff308A99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'elderly';
                  });

                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreenEldery(),
                      ),
                    );
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == 'elderly'
                      ? Color(0xff308A99)
                      : Colors.white,
                  minimumSize: const Size(300, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xff308A99),
                  ),
                ),
                child: Text(
                  "Sign Up as elderly",
                  style: TextStyle(
                    fontSize: 18,
                    color: _selectedRole == 'elderly'
                        ? Colors.white
                        : Color(0xff308A99),
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