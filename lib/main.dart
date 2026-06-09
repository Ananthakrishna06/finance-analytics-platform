import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'providers/currency_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrencyProvider()..loadCurrency(),
      child: SavrApp(),
    ),
  );
}

class SavrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen()
    );
  }
}



// build successful, but currency not loading on home screen, only on settings screen. Need to figure out how to trigger a reload of the home screen when returning from settings.
//verify in the morning it''s laggy
