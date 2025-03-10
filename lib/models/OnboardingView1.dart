import 'package:flutter/material.dart';

class OnboardingView1 extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  OnboardingView1({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image,
            height: screenHeight * 0.6,
            width: screenWidth,
            fit: BoxFit.cover,
          ),
          SizedBox(height: screenHeight * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Dynamic spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              description,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              maxLines: 5, // Avoid overflow
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
