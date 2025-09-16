import 'package:flutter/material.dart';

import 'notification_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';
import 'legal_screen.dart';

import 'home_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool fingerprintEnabled = true;

  final Color gradientStart = const Color(0xFF6E3C1B);
  final Color gradientMiddle = const Color(0xFFF8BE3B);
  final Color gradientEnd = const Color(0xFF6E3C1B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildOptionButton('Notification', context, NotificationScreen()),
            const SizedBox(height: 10),
            _buildOptionButton('Contact Us', context, ContactUsScreen()),
            const SizedBox(height: 30),

            const Text(
              'Security',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildFingerprintToggle(),
            const SizedBox(height: 10),
            _buildOptionButton('Privacy Policy', context, PrivacyPolicyScreen()),
            const SizedBox(height: 10),
            _buildOptionButton('Legal', context, LegalScreen()),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                        (route) => false,
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [gradientStart, gradientMiddle, gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String title, BuildContext context, Widget screen) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerprintToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Face ID',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          CustomGradientSwitch(
            value: fingerprintEnabled,
            onChanged: (val) {
              setState(() {
                fingerprintEnabled = val;
              });
            },
            gradientColors: [gradientStart, gradientMiddle, gradientEnd],
            borderColor: gradientMiddle,
          ),
        ],
      ),
    );
  }
}

class CustomGradientSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final List<Color> gradientColors;
  final Color borderColor;

  const CustomGradientSwitch({
    required this.value,
    required this.onChanged,
    required this.gradientColors,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? borderColor : Colors.transparent,
            width: value ? 1.5 : 0,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: value ? LinearGradient(colors: gradientColors) : null,
            color: value ? null : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
