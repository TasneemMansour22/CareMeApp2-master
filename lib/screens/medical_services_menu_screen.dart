import 'package:flutter/material.dart';

import 'ConsultationsScreen.dart';
import 'MedicationListScreen.dart';
import 'ServiceProviderScreen.dart';

class MedicalServicesMenuScreen extends StatelessWidget {
  final String seniorId; // Add this parameter

  const MedicalServicesMenuScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icon or Image
              Center(
                child: Image.asset(
                  'assets/images/icon.jpeg', // Replace with your actual image path
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Medical Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Add Medicine Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationListScreen(
                        seniorId: seniorId, isSenior: true, // Pass the seniorId here
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Add Medicine',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Medical Consultation Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsultationsScreen(
                        seniorId: seniorId, consultationType: 'Medical',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: const BorderSide(color: Color(0xFF308A99), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Medical Consultation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF308A99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Choose Medical Consultant Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderScreen(
                        seniorId: seniorId, serviceType: 'Medical',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: const BorderSide(color: Color(0xFF308A99), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Choose your medical consultant',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF308A99),
                    ),
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
