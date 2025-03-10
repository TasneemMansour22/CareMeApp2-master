import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/screens/zoom_provider.dart';


class ZoomSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zoomProvider = Provider.of<ZoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Zoom Settings", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF308A99),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Adjust Zoom Level",
              style: TextStyle(fontSize: 18 * zoomProvider.scaleFactor),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF308A99),  // Active track color
                inactiveTrackColor: Colors.grey,  // Inactive track color
                thumbColor: const Color(0xFF308A99), // Thumb (circle) color
                overlayColor: const Color(0xFF308A99).withOpacity(0.3), // Glow effect
                valueIndicatorColor: const Color(0xFF308A99), // **Label background color**
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,  // **Label text color**
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Slider(
                value: zoomProvider.scaleFactor,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                label: "${(zoomProvider.scaleFactor * 100).toInt()}%", // Label text
                onChanged: (newZoom) {
                  zoomProvider.setZoomLevel(newZoom);
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308A99)),
              onPressed: () {
                zoomProvider.setZoomLevel(1.0); // Reset to default zoom
              },
              child: Text("Reset Zoom", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
