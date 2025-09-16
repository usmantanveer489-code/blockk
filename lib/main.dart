import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'Splash Screen/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();

  runApp(
      EasyLocalization(
        supportedLocales: const [
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
        ],
        path: 'assets/translations',
        assetLoader: const SingleFileAssetLoader('language.json'),
        fallbackLocale: const Locale('en'),
        child: const BlockfolioXApp(),
      )

  );
}

class BlockfolioXApp extends StatelessWidget {
  const BlockfolioXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home:  SplashScreen(),
    );
  }
}




class SingleFileAssetLoader extends AssetLoader {
  final String fileName;

  const SingleFileAssetLoader(this.fileName);

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) async {
    final data = await rootBundle.loadString('$fullPath/$fileName');
    final jsonResult = json.decode(data);
    return jsonResult[locale.languageCode] ?? {};
  }
}

