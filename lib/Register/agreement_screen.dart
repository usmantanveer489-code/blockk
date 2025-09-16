import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> termsParagraphs = [
      'terms_1'.tr(),
      'terms_2'.tr(),
      'terms_3'.tr(),
      'terms_4'.tr(),
      'terms_5'.tr(),
      'terms_6'.tr(),
      'terms_7'.tr(),
      'terms_8'.tr(),
      'terms_9'.tr(),
      'terms_10'.tr(),
      'terms_contact'.tr(),
    ];

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'terms_title'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: termsParagraphs
                              .map((paragraph) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(paragraph),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6E3C1B),
                              Color(0xFFF8BE3B),
                              Color(0xFF6E3C1B),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'i_agree'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Positioned(
                top: -10,
                right: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 26, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

