import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Supported locales
const supportedLocales = [
  Locale('en', 'US'),
  Locale('en', 'GB'),
  Locale('zh'), // Chinese
  Locale('es'), // Spanish
  Locale('ja'), // Japanese
  Locale('fr'), // French
  Locale('vi'), // Vietnamese
  Locale('ru'), // Russian
  Locale('it'), // Italian
  Locale('de'), // German
];

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static final Map<String, String> languageNames = {
    'en_US': 'English (US)',
    'en_GB': 'English (UK)',
    'zh': 'Chinese',
    'es': 'Spanish',
    'ja': 'Japanese',
    'fr': 'French',
    'vi': 'Vietnamese',
    'ru': 'Russian',
    'it': 'Italian',
    'de': 'German',
  };

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: ListView.builder(
        itemCount: supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = supportedLocales[index];
          final key = locale.countryCode != null
              ? '${locale.languageCode}_${locale.countryCode}'
              : locale.languageCode;

          final isSelected = locale == currentLocale;

          return ListTile(
            title: Text(languageNames[key] ?? key),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              _setLocale(context, locale);
            },
          );
        },
      ),
    );
  }

  void _setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'US');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Demo',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LanguageScreen(),
    );
  }
}
