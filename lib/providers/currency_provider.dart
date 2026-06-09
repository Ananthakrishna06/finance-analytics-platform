import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String oldCurrency = "£"; // Default currency

  String get currency => oldCurrency;

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    oldCurrency = prefs.getString('currency') ?? "£";
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    oldCurrency = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    oldCurrency = newCurrency;
    notifyListeners();
  }
}
