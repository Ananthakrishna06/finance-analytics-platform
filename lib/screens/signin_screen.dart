import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Signinin screen 
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  @override
  State<SigninScreen> createState() => _SignInScreenState();
}
class _SignInScreenState extends State<SigninScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  Future<void> signin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedPassword = prefs.getString('userPassword');
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter email & password")));
      return;
    }
    if (savedEmail == null || savedPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No account found")));
      return;
    }
    if (email.text == savedEmail && password.text == savedPassword) {
      await prefs.setBool('isLoggedIn', true);
      print("Login Success, Saved");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Invalid Input")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( resizeToAvoidBottomInset: true,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        // background color with gradient
        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( minHeight: MediaQuery.of(context).size.height),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   SizedBox(height: 42), // top space
                    Center(
                      child: Text( "SAVR", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 42),
                    Text( "Welcome back!", style: TextStyle( color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text( "Sign in to your account", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 30),
                    // EMAIL BOX
                    Text("Email", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email), // email icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none, // no border line
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // PASSWORD BOX
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password", style: TextStyle(color: Colors.white)),
                       // forgot password text (not working yet)
                        Text("Forgot password?", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: password,
                      obscureText: true, // hide password
                      decoration: InputDecoration(
                        filled: true,hintText: 'password',
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock), // lock icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // SIGN IN BUTTON (can click now)
                    GestureDetector(
                      onTap: signin,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEF476F),
                              Color(0xFFFF8C61),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text( "SIGN IN", style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 )),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // go to signup screen
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // moving to signup page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => SignupScreen(), 
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan( text: "Sign Up", style: TextStyle( color: Colors.blue )), //maybe change colour later
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}