import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 16.0; // Default size

  double get fontSize => _fontSize;

  void setFontSize(double newSize) {
    _fontSize = newSize.clamp(10.0, 40.0); // Set min/max limits
    notifyListeners(); // Triggers UI update
  }
}

