import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  final supportedLocales = const [
    Locale('en', 'US'),
    Locale('ur'), // Urdu
    Locale('hi'), // Hindi
    Locale('ar'), // Arabic
    Locale('zh'), // Chinese
    Locale('fr'), // French
    Locale('de'), // German
    Locale('es'), // Spanish
    Locale('it'), // Italian
    Locale('ja'), // Japanese
    Locale('ko'), // Korean
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
    Locale('tr'), // Turkish
  ];

  static final Map<String, String> languageNames = {
    'en_US': 'English (US)',
    'ur': 'Urdu',
    'hi': 'Hindi',
    'ar': 'Arabic',
    'zh': 'Chinese',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'it': 'Italian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'tr': 'Turkish',
  };

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "language".tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "search".tr(),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: supportedLocales.length,
              itemBuilder: (context, index) {
                final locale = supportedLocales[index];
                final key = locale.countryCode != null
                    ? '${locale.languageCode}_${locale.countryCode}'
                    : locale.languageCode;

                final isSelected =
                    locale.languageCode == currentLocale.languageCode;

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      context.setLocale(locale); // App language change
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              languageNames[key] ?? key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // ✅ selected check
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
