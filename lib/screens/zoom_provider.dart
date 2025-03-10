import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ZoomProvider with ChangeNotifier {
  double _scaleFactor = 1.0; // Default zoom level
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double get scaleFactor => _scaleFactor;

  // Load user-specific zoom level
  Future<void> loadZoomLevel() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('seniors').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      _scaleFactor = (userDoc['zoomLevel'] ?? 1.0).toDouble();
      notifyListeners();
    }
  }

  // Update zoom level for the specific user
  Future<void> setZoomLevel(double newScale) async {
    _scaleFactor = newScale.clamp(0.8, 2.0); // Min 80%, Max 200%
    notifyListeners();

    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('seniors').doc(user.uid).update({
      'zoomLevel': _scaleFactor,
    });
  }
  // Reset zoom when user logs out
  void resetZoom() {
    _scaleFactor = 1.0;

    notifyListeners();
  }
}
