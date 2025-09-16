import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: const Text(
          '''
Privacy Policy – BlockFolioX

At BlockFolioX, your privacy is a top priority. This Privacy Policy explains how we collect, use, and protect your information when you use our app and services.

1. Data Collection:
We may collect personal information including but not limited to your name, email address, contact details, device information, IP address, and transaction history. We also collect anonymized usage data to improve our services.

2. Use of Data:
Your data is used to provide account services, support trading activities, process transactions, and comply with legal obligations. We may also use your data to enhance security and personalize your experience.

3. Third-Party Services:
We may use trusted third-party providers for services such as identity verification, analytics, and cloud storage. These providers are contractually obligated to protect your data.

4. User Control:
You have the right to access, modify, or delete your personal data. You can update your information through the app or request data changes by contacting our support team.

5. Security:
We implement industry-standard security measures including encryption, two-factor authentication, and routine audits to safeguard your data.

6. Compliance:
BlockFolioX complies with applicable data protection regulations including GDPR and local privacy laws. We may disclose user data only as required by law or regulatory authorities.

7. Updates:
This Privacy Policy may be updated from time to time. Continued use of the app after updates constitutes your agreement to the revised policy.

8. Contact:
If you have questions about this Privacy Policy or how we handle your data, please contact us at: folioxblock@gmail.com

© 2025 BlockFolioX. All rights reserved.
          ''',
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
