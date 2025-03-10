import 'package:flutter/material.dart';

import 'ConsultationsScreen.dart';
import 'ServiceProviderScreen.dart';

class FamilyManagementScreen extends StatelessWidget {
  final String seniorId;

  FamilyManagementScreen({required this.seniorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Family Members"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/family.jpg', // Ensure this is in your assets
              height: 120,
            ),

            const SizedBox(height: 30),
            const Text(
              "Family Members",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF308A99),
              ),
            ),
            const SizedBox(height: 30),
            _buildOptionButton(
              context,
              "Add a Family Member",
              Icons.person_add,
                  () {
                _showAddFamilyMemberDialog(context);
              },
            ),
            SizedBox(height: 20),
            _buildOptionButton(
              context,
              "Make a Family Consultation  ",
              Icons.medical_services,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultationsScreen(seniorId: seniorId, consultationType: 'Family',),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            _buildOptionButton(
              context,
              " Family Members",
              Icons.family_restroom,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceProviderScreen(seniorId: seniorId, serviceType: 'Family member',),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF308A99),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showAddFamilyMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Family Member"),
          content: TextField(
            decoration: InputDecoration( labelText: "Enter Family Member's Email",
        labelStyle: TextStyle(color: Color(0xFF308A99)),
        focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF308A99)),

            ),
          ),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // Add request logic here
                Navigator.pop(context);
              },
              child: Text("Send Request", style: TextStyle(color: Color(0xFF308A99))),
            ),
          ],
        );
      },
    );
  }

}
