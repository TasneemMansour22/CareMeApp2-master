import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddConsultationScreen.dart';
import 'MyConsultationsScreen.dart';
import 'MyRequestsScreen.dart';
import 'MySeniorsScreen.dart';
import 'ServiceProviderProfileScreen.dart';

class ServiceProviderDashboard extends StatefulWidget {
  final String userId;

  const ServiceProviderDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _ServiceProviderDashboardState createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  String userName = "User";
  String userRole = "";
  String profileImage = "assets/default_avatar.png"; // Default profile image
  String roleBasedImage = "assets/images/medical.jpeg"; // Default role icon

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('other_users').doc(widget.userId).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['fullName'] ?? "User";
          userRole = data?['role'] ?? "";
          profileImage = data?['profile_image'] ?? "assets/default_avatar.png";

          // Determine which role-based image to use
          if (userRole.toLowerCase() == "medical") {
            roleBasedImage = "assets/images/medical.jpeg"; // Medical role icon
          } else if (userRole.toLowerCase() == "legal & financial") {
            roleBasedImage = "assets/images/legal.jpeg"; // Legal role icon
          }
          else if (userRole.toLowerCase() == "family member") {
            roleBasedImage = "assets/images/family.jpg";}
          else {
            roleBasedImage = "assets/default_role.png"; // Fallback icon
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user data: $e")),
      );
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProviderProfileScreen(userId: widget.userId, isReadOnly: false,),
      ),
    );
  }

  void _navigateToNotifications() {
    // TODO: Implement notifications navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: _navigateToProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: _navigateToNotifications,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(roleBasedImage, height: 120), // Load role-based image dynamically
            const SizedBox(height: 20),
            const Text(
              "Seniors Management",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildMainButton("My Seniors", const Color(0xff308A99), () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MySeniorsScreen(
                  userId: widget.userId, // Pass the correct senior ID
                ),
              ),
            ),),
            const SizedBox(height: 16),
            _buildOutlinedButton("My Consultation",  () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyConsultationsScreen(

                ),
              ),
            ),),
            const SizedBox(height: 16),
            _buildOutlinedButton("My Requests", () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyRequestsScreen(
                  userId: widget.userId, // Pass the correct senior ID
                ),
              ),
            ),),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff308A99), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xff308A99), fontSize: 18)),
      ),
    );
  }
}
