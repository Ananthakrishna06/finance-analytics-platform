import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/signin_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';

// I think StatelessWidget is fine here...
class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [ Color(0xFF0B132B), Color(0xFF1C2541)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2), // to push content to the center
            Text( "SAVR", style: TextStyle( color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold )),
            Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40), 
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // go to Signin screen
                      Navigator.pushReplacement( context,
                        MaterialPageRoute( builder: (context) => SigninScreen()),
                      );
                      // I tried using pushReplacement before but it was weird so removed it
                      // now i realized push replacement is what works best🥲
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.white, // white button
                      foregroundColor: Colors.black, // black text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // rounded corners
                      ),
                    ),
                    child: Text("SIGN IN"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // go to signup
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (c) {return SignupScreen();}),
                      );

                    // maybe I should make a function for navigation... later
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.white, // white button
                      foregroundColor: Colors.black, // black text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // rounded corners
                      ),
                    ),
                    child: Text("SIGN UP"),
                  ),

                  // I thought of adding a third button here but skipped for now
                  // ElevatedButton(onPressed: () {}, child: Text("TEST"))
                ],
              ),
            ),

            SizedBox(height: 50), // bottom space 
          ],
        ),
      ),
    );
  }
}