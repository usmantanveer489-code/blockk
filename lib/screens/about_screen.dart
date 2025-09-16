import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final Color gradientStart = const Color(0xFF6E3C1B);
  final Color gradientMiddle = const Color(0xFFF8BE3B);
  final Color gradientEnd = const Color(0xFF6E3C1B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Our App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [gradientStart, gradientMiddle, gradientEnd],
                  ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientMiddle, gradientEnd],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Welcome to our app! This app is designed to provide the best experience for managing your tasks and staying organized. Our goal is to help you achieve more with less effort by providing a clean and intuitive interface, powerful features, and seamless performance.

We continuously work to improve and add new features based on your feedback. Thank you for choosing our app, and we hope you enjoy using it!

If you have any questions or feedback, feel free to reach out to our support team.

© 2025 BlockFolioX. All rights reserved.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
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
                      'Go Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
