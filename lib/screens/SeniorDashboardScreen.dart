import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:test1/screens/FontSizeSettingsScreen.dart';
import 'package:test1/screens/account_type_screen.dart';
import 'package:test1/screens/zoom_provider.dart';
import 'package:test1/screens/zoom_settings_screen.dart';
import 'AddBankCardScreen.dart';
import 'AddElectronicWalletScreen.dart';
import 'Add_medication_screen.dart';
import 'AppointmentCalendarScreen.dart';
import 'BasicInformationScreen.dart';
import 'ChangePasswordScreen.dart';
import 'FamilyManagementScreen.dart';
import 'MedicalInfoScreen.dart';
import 'MedicationListScreen.dart';
import 'MyConsultationsScreen.dart';
import 'bill_payments_screen.dart';
import 'login_screen.dart';

class SeniorDashboardScreen extends StatefulWidget {
  final String seniorId;

  const SeniorDashboardScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  State<SeniorDashboardScreen> createState() => _SeniorDashboardScreenState();
}

class _SeniorDashboardScreenState extends State<SeniorDashboardScreen> {
  String seniorName = '';
  bool isLoading = true;
  bool isMedicalProvider = false;
  bool isLegalOrFinancialProvider = false;

  @override
  void initState() {
    super.initState();
    _fetchSeniorName();
    _checkIfServiceProvider(); // New function to determine user role
  }

  Future<void> _checkIfServiceProvider() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('other_users').doc(user.uid).get();
      if (doc.exists) {
        String role = doc['role'];
        if (role == 'Medical') {
          setState(() {
            isMedicalProvider = true;
          });
        } else if (role == 'Legal & Financial') {
          setState(() {
            isLegalOrFinancialProvider = true;
          });
        }
      }
    }
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Icon(Icons.logout, size: 50, color: Color(0xFF308A99)), // Logout Icon
              const SizedBox(height: 10),
              Text(
                "Are you sure to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: _logoutUser, // Call the logout function
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF308A99), // Button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
  Future<void> _logoutUser() async {
    try {
      final zoomProvider = Provider.of<ZoomProvider>(context, listen: false);
      zoomProvider.resetZoom();
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pop(context); // Close the dialog
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/accountTypeScreen',  // Navigate to Choose Account Screen
            (route) => false,  // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout Failed: $e")),
      );
    }
  }

  void _showAddFamilyMemberDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Family Member"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Enter Family Member's Email",
              labelStyle: TextStyle(color: Color(0xFF308A99)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF308A99)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => _sendFamilyRequest(emailController.text),
              child: const Text("Send Request", style: TextStyle(color: Color(0xFF308A99))),
            ),
          ],
        );
      },
    );
  }
  Future<void> _sendFamilyRequest(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email!")),
      );
      return;
    }

    try {
      // Check if email exists in other_users
      final querySnapshot = await FirebaseFirestore.instance
          .collection('other_users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this email.")),
        );
        return;
      }

      final familyMember = querySnapshot.docs.first;
      final familyMemberId = familyMember.id;
      final familyMemberName = familyMember['fullName'];

      // Create a team request for family member
      await FirebaseFirestore.instance.collection('team_requests').add({
        'senior_id': widget.seniorId,
        'user_id': familyMemberId,
        'user_name': familyMemberName,
        'status': 'requested',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request sent successfully!")),
      );
      Navigator.pop(context); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Future<void> _fetchSeniorName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('seniors').doc(widget.seniorId).get();
      if (doc.exists) {
        setState(() {
          seniorName = doc['fullName'] ?? 'Unknown';
          isLoading = false;
        });
      } else {
        setState(() {
          seniorName = 'Unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching senior's name: $e");
      setState(() {
        seniorName = 'Unknown';
        isLoading = false;
      });
    }
  }

  Future<void> _authenticateUser() async {
    String password = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Enter Your Password",
            style: TextStyle(color: Color(0xFF308A99)), // Updated color
          ),
          content: TextField(
            obscureText: true,
            onChanged: (value) => password = value,
            decoration: const InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Color(0xFF308A99)), // Updated color
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF308A99)), // Updated color
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                User? user = FirebaseAuth.instance.currentUser;
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: password,
                  );
                  await user.reauthenticateWithCredential(credential);
                  _showPaymentOptions();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect password. Try again!")),
                  );
                }
              },
              child: const Text(
                "Verify",
                style: TextStyle(color: Color(0xFF308A99)), // Updated color
              ),
            ),
          ],
        );
      },
    );
  }


  void _showPaymentOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Payment Method",
            style: TextStyle(color: Color(0xFF308A99)),
          ),
          content: const Text("How would you like to proceed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddBankCardScreen(seniorId: widget.seniorId)),
        ),
              child: const Text("Bank Card",
                style: TextStyle(color: Color(0xFF308A99)),
              ),
            ),
            TextButton(
              onPressed:  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddElectronicWalletScreen(seniorId: widget.seniorId)),
              ),
              child: const Text("Electronic Wallet",
                style: TextStyle(color: Color(0xFF308A99)),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigates back to the previous screen
          },
        ),
      ),
      backgroundColor: const Color(0xFF308A99),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              seniorName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (isMedicalProvider) ...[
                      _ProfileOption(
                          icon: Icons.info,
                          label: "Basic Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BasicInformationScreen(seniorId: widget.seniorId, isSenior: false),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.medical_services,
                          label: "Medical Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicalInfoScreen(seniorId: widget.seniorId, isReadOnly: true),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.medication,
                          label: "Medications List",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicationListScreen(seniorId: widget.seniorId, isSenior: false),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.note_add,
                          label: "Add Medicine",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMedicationScreen(seniorId: widget.seniorId, medication: null),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.chat,
                          label: "Consultations",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyConsultationsScreen(seniorId: widget.seniorId),
                              ),
                            );
                          }),
                    ] else if (isLegalOrFinancialProvider) ...[
                      _ProfileOption(
                          icon: Icons.info,
                          label: "Basic Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BasicInformationScreen(seniorId: widget.seniorId, isSenior: false),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.chat,
                          label: "Consultations",//
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyConsultationsScreen(seniorId: widget.seniorId),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.payment,
                          label: "Bill Payment",
                          onTap:  () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>BillPaymentScreen(seniorId: widget.seniorId),
                              ),
                            );
                          }),
                    ] else ...[
                      _ProfileOption(
                          icon: Icons.info,
                          label: "Register Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BasicInformationScreen(seniorId: widget.seniorId, isSenior: true),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.calendar_today,
                          label: "Appointment",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentCalendarScreen(seniorId: widget.seniorId),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.payment,
                          label: "Payment Method",
                          onTap: _authenticateUser),
                      _ProfileOption(
                          icon: Icons.password,
                          label: "Change Password",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.medical_services,
                          label: "Medical Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicalInfoScreen(seniorId: widget.seniorId, isReadOnly: false),
                              ),
                            );
                          }),
                      _ProfileOption(
                          icon: Icons.group_add,
                          label: "Add Family Member",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FamilyManagementScreen(seniorId: widget.seniorId),
                              ),
                            );
                          }),
                      _ProfileOption(
                        icon: Icons.zoom_in,
                        label: "Zoom Settings",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ZoomSettingsScreen()),
                          );
                        },
                      ),

                      _ProfileOption(
                        icon: Icons.logout,
                        label: "Logout",
                        onTap: _showLogoutDialog,
                        isLogout: true,
                      ),
                    ],

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}




class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
