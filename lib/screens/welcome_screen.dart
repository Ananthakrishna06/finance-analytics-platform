import 'package:flutter/material.dart';
import 'starting_screen.dart';
import 'signin_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Stateful, because animation is involved...
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool shouldAnimate = false; 
  @override //to edit a existing method and add my logic to it
  void initState() { //runs the app when it's first loaded
    super.initState();
    checkLogin();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {shouldAnimate = true;});
    });
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) {   // using ctx instead of context just because 😅
            return StartingScreen();
          },
        ),
      );
    });
    // I originally thought of using Timer instead of Future.delayed but idk i just felt like..
    // Timer(Duration(seconds: 4), () {});
  }
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    await Future.delayed(const Duration(seconds: 3));
    if (isLoggedIn) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
    } else { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SigninScreen()));
    }
    // this is gonna verify if the user has already logged in. yes - home, no - signin. 
  }
  @override
  Widget build(BuildContext context) {
    final gradientColors = [ Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFFEF476F)];
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: shouldAnimate ? Alignment.bottomLeft : Alignment.topRight,
            end: shouldAnimate ? Alignment.topRight : Alignment.bottomLeft,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: Text("S", style: TextStyle( fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold )),
        ),
      ),
    );
  }
}