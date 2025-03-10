import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBillScreen extends StatefulWidget {
  final String seniorId;
  final String billType;
  final Map<String, dynamic>? bill; // For edit functionality

  const AddBillScreen({
    Key? key,
    required this.seniorId,
    required this.billType,
    this.bill,
  }) : super(key: key);

  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPaymentMethod = 'Bank Card'; // Default value
  DateTime? _dueDate;
  String _billStatus = "Unpaid"; // Default value


  final List<String> _paymentMethods = [
    'Bank Card',
    'Electronic Wallet',
    'Cash'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _amountController.text = widget.bill!['amount_due'].toString();
      _selectedPaymentMethod = widget.bill!['payment_method'] ?? 'Bank Card';
      _dueDate = (widget.bill!['due_date'] as Timestamp).toDate();
      _billStatus = widget.bill?['status'] ?? "Unpaid";

    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: (_dueDate != null && _dueDate!.isAfter(DateTime.now()))
          ? _dueDate!
          : DateTime.now(),

      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF308A99),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _saveBill() async {
    if (_amountController.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final billData = {
      'senior_id': widget.seniorId,
      'bill_type': widget.billType,
      'due_date': Timestamp.fromDate(_dueDate!),
      'amount_due': double.tryParse(_amountController.text) ?? 0.0,
      'payment_method': _selectedPaymentMethod,
      'status': _billStatus, // Add this
    };

    if (widget.bill == null) {
      // Add new bill
      await FirebaseFirestore.instance.collection('Bills').add(billData);
    } else {
      // Update existing bill
      await FirebaseFirestore.instance
          .collection('Bills')
          .doc(widget.bill!['id'])
          .update(billData);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? "Add ${widget.billType}" : "Edit Bill"),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Due Date Picker
            TextButton(
              onPressed: _selectDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dueDate == null
                        ? "Select Due Date"
                        : "Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(
                      color: Color(0xFF308A99),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Color(0xFF308A99)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",labelStyle: TextStyle(color: Color(0xFF308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: _paymentMethods
                  .map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val!;
                });
              },
              decoration: InputDecoration(
                labelText: "Payment Method",labelStyle: TextStyle(color: Color(0xFF308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Dropdown
            DropdownButtonFormField<String>(
              value: _billStatus,
              items: ["Paid", "Unpaid"].map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _billStatus = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Bill Status",labelStyle: TextStyle(color: Color(0xFF308A99)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308A99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  widget.bill == null ? "Add Bill" : "Save Changes",
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