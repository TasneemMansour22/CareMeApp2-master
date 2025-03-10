import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddBankCardScreen.dart';
import 'AddElectronicWalletScreen.dart';
import 'MyBillsScreen.dart';
import 'add_bill_screen.dart';

class BillPaymentScreen extends StatefulWidget {
  final String seniorId;

  const BillPaymentScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _BillPaymentScreenState createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {

  void _navigateToElectronicWalletData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddElectronicWalletScreen(seniorId: widget.seniorId),
      ),
    );
  }

  void _navigateToMyBills() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyBillsScreen(seniorId: widget.seniorId),
      ),
    );
  }

  void _navigateToAddBill(String billType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillScreen(
          seniorId: widget.seniorId,
          billType: billType,
        ),
      ),
    ).then((_) => setState(() {})); // Refresh the list after returning
  }
  void _showOtherBillDialog() {
    TextEditingController billNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Bill Type", style: TextStyle(color: const Color(0xFF308A99),),),
          content: TextField(
            controller: billNameController,
            decoration: const InputDecoration(
              hintText: "Type your bill name...",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF308A99)), // Change focused border color
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel", style: TextStyle(color: const Color(0xFF308A99),),),
            ),
            TextButton(
              onPressed: () {
                String customBill = billNameController.text.trim();
                if (customBill.isNotEmpty) {
                  Navigator.pop(context);
                  _navigateToAddBill(customBill); // Pass custom bill type
                }
              },
              child: const Text("OK", style: TextStyle(color: const Color(0xFF308A99),),),
            ),
          ],
        );
      },
    );
  }

  void _authenticateAndNavigate(BuildContext context) async {
    String? password = await _promptForPassword(context);

    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed.")),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);

      // If authentication is successful, navigate to the AddBankCardScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddBankCardScreen(seniorId: user.uid)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication failed: $e")),
      );
    }
  }
  void _authenticateAndNavigate2(BuildContext context) async {
    String? password = await _promptForPassword(context);

    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed.")),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);

      // If authentication is successful, navigate to the AddBankCardScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddElectronicWalletScreen(seniorId: user.uid)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication failed: $e")),
      );
    }
  }

  Future<String?> _promptForPassword(BuildContext context) async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _passwordController = TextEditingController();
        return AlertDialog(
          title: const Text("Authentication Required",
            style: TextStyle(color: const Color(0xFF308A99),),
          ),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: const TextStyle(color: Colors.grey),

              // Change the underline color
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: const BorderSide(color: Color(0xFF308A99), width: 2), // Your app color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF308A99), width: 1.5), // Your app color
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF308A99)), // Your app color
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel",
                style: TextStyle(color: Colors.white),
              ),
              style:TextButton.styleFrom(backgroundColor:Color(0xFF308A99), ),
            ),
            ElevatedButton(
              onPressed: () {
                password = _passwordController.text;
                Navigator.of(context).pop();
              },
              child: const Text("Submit",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF308A99),),
            ),
          ],
        );
      },
    );
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Payment'),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most Used Services Grid
            const Text(
              'Most used services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  _buildServiceTile('Mobile ', 'assets/images/mobile_bill.jpeg', 'Mobile_bill'),
                  _buildServiceTile('Internet ', 'assets/images/internet.jpeg', 'Internet_bill'),
                  _buildServiceTile('Car', 'assets/images/car.png', 'Car'),
                  _buildServiceTile('Water ', 'assets/images/water.jpeg', 'Water_bill'),
                  _buildServiceTile('Electricity', 'assets/images/electricity.jpeg', 'Electricity'),
                  _buildServiceTile('Landline', 'assets/images/telephone.jpeg', 'Landline'),
                  _buildServiceTile('Insurance', 'assets/images/social_insurance.jpeg', 'Insurance'),
                  _buildServiceTile('Tickets', 'assets/images/tickets.jpeg', 'Tickets'),
                  _buildServiceTile('Gas', 'assets/images/gas.png', 'Gas'),
                  _buildServiceTile('Donations', 'assets/images/donation.png', 'Donations'),
                  _buildServiceTile('Tax', 'assets/images/tax.png', 'Tax'),
                  _buildServiceTile('Other', 'assets/images/other.jpg', 'other'),
                ],
              
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Buttons Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed: _navigateToMyBills,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308A99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'My Bills',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed: () => _authenticateAndNavigate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308A99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Bank Card Data',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed: () => _authenticateAndNavigate2(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308A99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Electronic Wallet Data',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildServiceTile(String label, String imagePath, String billType) {
    return GestureDetector(
      onTap: () {
        if (billType == "other") {
          _showOtherBillDialog(); // Show input dialog for "Other"
        } else {
          _navigateToAddBill(billType);
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                height: 30,
                width: 30,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
