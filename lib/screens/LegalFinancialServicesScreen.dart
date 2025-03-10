import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ConsultationsScreen.dart';
import 'ServiceProviderScreen.dart';

class LegalFinancialServicesScreen extends StatelessWidget {
  final String seniorId;  // Pass the senior ID

  const LegalFinancialServicesScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Legal & Financial Services"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/legal_financial.jpeg', // Ensure this is in your assets
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              "Legal & Financial Services",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF308A99),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderScreen(
                        seniorId: seniorId, serviceType: 'Legal & Financial',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Choose Your Legal & Financial Consultant",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultationsScreen(
                          seniorId: seniorId, consultationType: 'Legal&Financial',
                        ),
                      ),
                    );

                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF308A99),
                  side: const BorderSide(color: Color(0xFF308A99)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Legal & Financial Consultations",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
