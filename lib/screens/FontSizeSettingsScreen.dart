import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeSettingsScreen extends StatefulWidget {
  @override
  _FontSizeSettingsScreenState createState() => _FontSizeSettingsScreenState();
}

class _FontSizeSettingsScreenState extends State<FontSizeSettingsScreen> {
  double _fontSize = 16.0; // Default font size

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  // Load saved font size from SharedPreferences
  Future<void> _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  // Save selected font size
  Future<void> _saveFontSize(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    setState(() {
      _fontSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Size Settings"),
        backgroundColor: Color(0xFF308A99),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Text Size:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildFontSizeOption("Small", 14.0),
            _buildFontSizeOption("Medium (Default)", 16.0),
            _buildFontSizeOption("Large", 20.0),

            const SizedBox(height: 20),
            const Text("Preview:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "This is a preview text.",
              style: TextStyle(fontSize: _fontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: size)),
      trailing: Radio(
        value: size,
        groupValue: _fontSize,
        onChanged: (value) {
          _saveFontSize(value as double);
        },
      ),
    );
  }
}
