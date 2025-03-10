import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/screens/technical_support.dart';
import 'AddMedicalInfoScreen.dart';
import 'DocumentManagementScreen.dart';
import 'LegalFinancialServicesScreen.dart';
import 'MedicationListScreen.dart';
import 'SeniorDashboardScreen.dart';
import 'bill_payments_screen.dart';
import 'medical_services_menu_screen.dart';
import 'SocialActivitiesListScreen.dart';

class HomePage extends StatefulWidget {
  final String senior_id; // Accept the userId from the login screen

  const HomePage({super.key, required this.senior_id});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = ''; // To store the user's name
  bool isLoading = true; // To show a loading spinner while fetching data

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();


  }


  void navigateToMedicalServices(String seniorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Medical_data')
        .doc(seniorId)
        .get();

    if (doc.exists) {
      // Navigate to main Medical Services screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalServicesMenuScreen(seniorId: widget.senior_id,),
        ),
      );
    } else {
      // Navigate to Add Medical Info screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMedicalInfoScreen(seniorId: seniorId),
        ),
      );
    }
  }
  Future<void> _fetchUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('seniors') // Replace with your Firestore collection name
          .doc(widget.senior_id)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          userName = userData?['fullName'] ?? 'Unknown'; // Fetch the user's name
          isLoading = false; // Stop loading spinner
        });
      } else {
        setState(() {
          userName = 'Unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with User Info
            Container(
              padding:
              const EdgeInsets.only(top: 80.0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the user's profile screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeniorDashboardScreen(seniorId: widget.senior_id), // Replace `UserProfileScreen` with the actual screen you want to navigate to
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName, // Display the fetched user name
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Actions
                  const Row(
                    children: [
                      Icon(Icons.notifications_none,
                          color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Add space after top section

            // Header Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/home_image.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Services Grid
            Padding(
              padding: const EdgeInsets.only(top: 30.0,left: 16,right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),

                    children: [
                      _buildServiceCard('Medical Services', 'assets/images/medical_services.png', () => navigateToMedicalServices(widget.senior_id),),
                      _buildServiceCard('Social Activities', 'assets/images/social_activities.png',   () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialActivitiesListScreen(
                            seniorId: widget.senior_id, // Pass the correct senior ID
                          ),
                        ),
                      ),
                      ),
                      _buildServiceCard('Document Management', 'assets/images/document_management.png', () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentManagementScreen(
                            seniorId: widget.senior_id, // Pass the correct senior ID
                          ),
                        ),
                      ),),//B
                      _buildServiceCard('Bill Payment', 'assets/images/bill_payment.png', () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillPaymentScreen(
                            seniorId: widget.senior_id, // Pass the correct senior ID
                          ),
                        ),
                      ),
                      ),
                      _buildServiceCard('Technical Support', 'assets/images/technical_support.png', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TechnicalSupportScreen(),
                          ),
                        );
                      }),
                      _buildServiceCard('Legal and Financial Services', 'assets/images/legal_and_financial_advice.png', ()  => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LegalFinancialServicesScreen(
                            seniorId: widget.senior_id, // Pass the correct senior ID
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure the column doesn't expand unnecessarily
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent, // Ensure the background is transparent
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                height: 80, // Adjust the height to fit within the grid
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}