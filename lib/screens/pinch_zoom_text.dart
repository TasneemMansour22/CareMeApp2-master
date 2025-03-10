import 'package:flutter/material.dart';

class PinchZoomText extends StatefulWidget {
  final String text; // The text to display
  final double initialFontSize; // Default font size

  PinchZoomText({required this.text, this.initialFontSize = 20.0});

  @override
  _PinchZoomTextState createState() => _PinchZoomTextState();
}

class _PinchZoomTextState extends State<PinchZoomText> {
  double _fontSize = 20.0; // Default font size
  double _baseFontSize = 20.0;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _baseFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          _fontSize = (_baseFontSize * details.scale).clamp(12.0, 50.0); // Min: 12, Max: 50
        });
      },
      onScaleEnd: (ScaleEndDetails details) {
        _baseFontSize = _fontSize;
      },
      child: Text(
        widget.text,
        style: TextStyle(fontSize: _fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }
}
