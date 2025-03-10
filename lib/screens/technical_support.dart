import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TechnicalSupportScreen extends StatefulWidget {
  @override
  _TechnicalSupportScreenState createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen> {
  List<Map<String, String>> supportServices = [];
  bool isLoading = true; // To track loading state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchTechnicalSupportNumbers();
  }

  Future<void> fetchTechnicalSupportNumbers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('other_users')
          .where('role', isEqualTo: 'Technical Support')
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          supportServices = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, String>> fetchedSupport = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>?;

        return {
          "name": data?["fullName"]?.toString() ?? "Unknown",
          "phone": data?["phone"]?.toString() ?? "N/A",
          "imageUrl": data?["profileImageUrl"]?.toString() ?? "",
        };
      }).toList();

      setState(() {
        supportServices = fetchedSupport;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching technical support contacts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to filter support services based on the search query
  List<Map<String, String>> _getFilteredSupportServices() {
    if (_searchQuery.isEmpty) {
      return supportServices;
    } else {
      return supportServices.where((service) {
        return service["name"]!.toLowerCase().contains(_searchQuery) ||
            service["phone"]!.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Text("Technical Support"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF308A99)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF308A99), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF308A99)),
                ),
              ),
              cursorColor: const Color(0xFF308A99),
            ),
            const SizedBox(height: 15),
            const Text(
              "Best Technical Support Services",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _getFilteredSupportServices().isEmpty
                  ? const Center(
                child: Text(
                  "No technical support contacts available.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _getFilteredSupportServices().length,
                itemBuilder: (context, index) {
                  return _buildSupportCard(
                    _getFilteredSupportServices()[index]["name"] ??
                        "Unknown",
                    _getFilteredSupportServices()[index]["phone"] ??
                        "N/A",
                    _getFilteredSupportServices()[index]["imageUrl"] ??
                        "",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(String name, String phone, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
                : _buildPlaceholderImage(),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phone,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: phone != "N/A" ? () => _launchPhoneDialer(phone) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF308A99),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Call Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/phone.png',
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}