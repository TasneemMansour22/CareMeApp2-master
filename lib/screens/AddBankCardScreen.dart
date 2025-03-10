import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AddBankCardScreen extends StatefulWidget {
  final String seniorId;

  const AddBankCardScreen({Key? key, required this.seniorId}) : super(key: key);

  @override
  _AddBankCardScreenState createState() => _AddBankCardScreenState();
}

class _AddBankCardScreenState extends State<AddBankCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;

  // 32-character encryption key (AES requires 16, 24, or 32 characters)
  final String encryptionKey = "thisIsA32CharacterLongSecretKey!@#123";

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  // Encrypt CVV before storing
  String _encryptCVV(String cvv) {
    final key = encrypt.Key.fromUtf8('12345678901234567890123456789012'); // 32-byte key
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(cvv, iv: iv);
    return '${iv.base64}:${encrypted.base64}'; // Store IV and encrypted data
  }


  // Decrypt CVV before displaying
  String _decryptCVV(String encryptedCVV) {
    try {
      final key = encrypt.Key.fromUtf8('12345678901234567890123456789012'); // 32-byte key
      final parts = encryptedCVV.split(':'); // Extract IV and encrypted data
      if (parts.length != 2) return 'Error'; // Handle invalid format

      final iv = encrypt.IV.fromBase64(parts[0]); // Get IV
      final encryptedData = parts[1];

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt64(encryptedData, iv: iv);
    } catch (e) {
      return 'Error'; // Handle decryption errors
    }
  }


  Future<void> _fetchCardData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PaymentMethods')
          .where('senior_id', isEqualTo: widget.seniorId)
          .where('type', isEqualTo: 'bank_card')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final cardData = snapshot.docs.first.data();
        _cardNumberController.text = cardData['card_number'] ?? '';
        _cardHolderNameController.text = cardData['card_holder_name'] ?? '';
        _expiryDateController.text = cardData['expiry_date'] ?? '';
        _cvvController.text = _decryptCVV(cardData['cvv']);

        setState(() {
          _isUpdating = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching card data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrUpdateCardData() async {
    if (_cardNumberController.text.isEmpty ||
        _cardHolderNameController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final cardData = {
      'senior_id': widget.seniorId,
      'card_number': _cardNumberController.text,
      'card_holder_name': _cardHolderNameController.text,
      'expiry_date': _expiryDateController.text,
      'cvv': _encryptCVV(_cvvController.text),
      'type': 'bank_card',
    };

    try {
      if (_isUpdating) {
        final snapshot = await FirebaseFirestore.instance
            .collection('PaymentMethods')
            .where('senior_id', isEqualTo: widget.seniorId)
            .where('type', isEqualTo: 'bank_card')
            .get();

        if (snapshot.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('PaymentMethods')
              .doc(snapshot.docs.first.id)
              .update(cardData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bank Card Updated Successfully")),
          );
        }
      } else {
        await FirebaseFirestore.instance.collection('PaymentMethods').add(cardData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bank Card Saved Successfully")),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdating ? "Update Bank Card" : "Add Bank Card"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Card Number", _cardNumberController),
            _buildTextField("Card Holder Name", _cardHolderNameController),
            _buildTextField("Expiry Date (MM/YY)", _expiryDateController),
            _buildTextField("CVV", _cvvController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveOrUpdateCardData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  _isUpdating ? "Update Bank Card" : "Save Bank Card",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF308A99)),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
