import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontSizeSettingsScreen extends StatefulWidget {
  @override
  _FontSizeSettingsScreenState createState() => _FontSizeSettingsScreenState();
}

class _FontSizeSettingsScreenState extends State<FontSizeSettingsScreen> {
  double _scaleFactor = 1.0; // Default zoom level

  @override
  void initState() {
    super.initState();
    _loadScaleFactor();
  }

  Future<void> _loadScaleFactor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scaleFactor = prefs.getDouble('scaleFactor') ?? 1.0;
    });
  }

  Future<void> _saveScaleFactor(double newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scaleFactor', newValue);
    setState(() {
      _scaleFactor = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Font & UI Zoom Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjust Zoom Level', style: TextStyle(fontSize: 18.sp * _scaleFactor)),
            Slider(
              value: _scaleFactor,
              min: 0.8, // Minimum zoom
              max: 2.0, // Maximum zoom
              divisions: 6,
              label: _scaleFactor.toStringAsFixed(1),
              onChanged: (value) {
                _saveScaleFactor(value);
              },
            ),
            SizedBox(height: 20.h),
            Text(
              'Preview Text',
              style: TextStyle(fontSize: 18.sp * _scaleFactor),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Save & Go Back', style: TextStyle(fontSize: 16.sp * _scaleFactor)),
            ),
          ],
        ),
      ),
    );
  }
}
