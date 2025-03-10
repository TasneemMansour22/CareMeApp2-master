import 'package:flutter/material.dart';

class GenderSelection extends StatefulWidget {
  const GenderSelection({super.key});

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String? selectedGender;

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Male Button
            Expanded(
              child: GestureDetector(
                onTap: () => selectGender("male"),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedGender == "male"
                        ? const Color(0xFFE8F1FC) // Selected background color
                        : const Color(0xFFF5F7FB), // Unselected background color
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selectedGender == "male"
                          ? const Color(0xFF308A99) // Selected border color
                          : Colors.transparent, // Unselected border color
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "male",
                        groupValue: selectedGender,
                        onChanged: (value) => selectGender(value!),
                        activeColor: const Color(0xFF308A99),
                      ),
                      const Text(
                        "Male",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Female Button
            Expanded(
              child: GestureDetector(
                onTap: () => selectGender("female"),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedGender == "female"
                        ? const Color(0xFFE8F1FC) // Selected background color
                        : const Color(0xFFF5F7FB), // Unselected background color
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selectedGender == "female"
                          ? const Color(0xFF308A99) // Selected border color
                          : Colors.transparent, // Unselected border color
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "female",
                        groupValue: selectedGender,
                        onChanged: (value) => selectGender(value!),
                        activeColor: const Color(0xFF308A99),
                      ),
                      const Text(
                        "Female",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
