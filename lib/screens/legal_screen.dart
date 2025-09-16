import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Legal',
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
BlockFolioX is a platform that facilitates cryptocurrency trading. Trading digital assets involves significant risk and may result in the loss of your invested capital. Prices can be volatile, and past performance is not indicative of future results.

By using this app, you agree that BlockFolioX is not responsible for any financial losses, system outages, or third-party service failures. You should consult a financial advisor before making investment decisions.

Use of BlockFolioX is subject to local regulations, and it is your responsibility to ensure compliance with your jurisdiction’s laws.

All content and services provided by BlockFolioX are for informational purposes only and do not constitute investment advice.

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
