import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AddElectronicWalletScreen extends StatefulWidget {
  final String seniorId;

  const AddElectronicWalletScreen({Key? key, required this.seniorId})
      : super(key: key);

  @override
  _AddElectronicWalletScreenState createState() =>
      _AddElectronicWalletScreenState();
}

class _AddElectronicWalletScreenState extends State<AddElectronicWalletScreen> {
  final TextEditingController _walletNumberController = TextEditingController();
  String? _selectedProvider;
  final List<String> _walletProviders = ["PayPal", "Google Pay", "Apple Pay", "Venmo", "Other"];
  final TextEditingController _otherProviderController = TextEditingController();
  bool _isUpdating = false;
  String? _documentId;

  // Encryption key (must be 32 characters for AES-256)
  final String encryptionKey = "12345678901234567890123456789012";

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  String _encryptWalletNumber(String walletNumber) {
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(walletNumber, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptWalletNumber(String encryptedWallet) {
    try {
      final key = encrypt.Key.fromUtf8(encryptionKey);
      final parts = encryptedWallet.split(':');
      if (parts.length != 2) return 'Error';
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = parts[1];
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt64(encryptedData, iv: iv);
    } catch (e) {
      return 'Error';
    }
  }

  Future<void> _fetchWalletData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PaymentMethods')
          .where('senior_id', isEqualTo: widget.seniorId)
          .where('type', isEqualTo: 'electronic_wallet')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final walletData = snapshot.docs.first.data();
        _documentId = snapshot.docs.first.id;
        _selectedProvider = walletData['wallet_provider'];
        _walletNumberController.text = _decryptWalletNumber(walletData['wallet_number']);

        if (!_walletProviders.contains(_selectedProvider)) {
          _selectedProvider = "Other";
          _otherProviderController.text = walletData['wallet_provider'];
        }

        setState(() {
          _isUpdating = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching wallet data: $e")),
      );
    }
  }

  Future<void> _saveElectronicWallet() async {
    if ((_selectedProvider == "Other" && _otherProviderController.text.isEmpty) ||
        _walletNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final walletData = {
      'senior_id': widget.seniorId,
      'wallet_provider': _selectedProvider == "Other" ? _otherProviderController.text : _selectedProvider,
      'wallet_number': _encryptWalletNumber(_walletNumberController.text),
      'type': 'electronic_wallet',
    };

    if (_isUpdating && _documentId != null) {
      await FirebaseFirestore.instance.collection('PaymentMethods').doc(_documentId).update(walletData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Electronic Wallet Updated Successfully")),
      );
    } else {
      await FirebaseFirestore.instance.collection('PaymentMethods').add(walletData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Electronic Wallet Saved Successfully")),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdating ? "Update Electronic Wallet" : "Add Electronic Wallet"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: InputDecoration(
                labelText: "Wallet Provider",
                labelStyle: const TextStyle(color: Color(0xFF308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _walletProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value;
                });
              },
            ),
            if (_selectedProvider == "Other") ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otherProviderController,
                decoration: InputDecoration(
                  labelText: "Enter Wallet Provider",
                  labelStyle: const TextStyle(color: Color(0xFF308A99)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _walletNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Wallet Number",
                labelStyle: const TextStyle(color: Color(0xFF308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveElectronicWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  _isUpdating ? "Update Wallet" : "Save Wallet",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
