import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'signin_screen.dart';
// signup screen (basic version)
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  Future<void> signup() async {
    final prefs = await SharedPreferences.getInstance();
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill all fields")));
      return;
    }
    await prefs.setString('userName', name.text);
    await prefs.setString('userEmail', email.text);
    await prefs.setString('userPassword', password.text);
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Account created!")));
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( resizeToAvoidBottomInset: true,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF0B132B),
              Color(0xFF1C2541), // same colors like other screens
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( minHeight: MediaQuery.of(context).size.height),
              child: IntrinsicHeight(
                // still not sure why this was needed but its working so leaving it for now
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Center(
                      child: Text( "SAVR", style: TextStyle( color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold )),
                    ),
                    SizedBox(height: 30),
                    Text( "Create your account", style: TextStyle( color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold )),
                    SizedBox(height: 8),
                    Text( "Sign up to get started", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 25),
                    // FULL NAME BOX
                    Text("Full name", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // EMAIL BOX
                    Text("Email", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress, // email keyboard
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // PASSWORD BOX
                    Text("Password", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    TextField(
                      controller: password,
                      obscureText: true, // hide text
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // CONFIRM PASSWORD (basically same as above, could reuse but didn't)
                    Text("Confirm Password", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock), // same icon again
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // CREATE ACCOUNT BUTTON 
                    GestureDetector(
                      onTap: () {
                        // for now just going to home screen without any validation or anything
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFF3A4A6B),
                        ),
                        child: Center(
                          child: Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // go back to Signin screen
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // going back (pop)
                          Navigator.pop(context);
                          // earlier I tried push but it stacked screens so using pop now
                        },
                        child: Text.rich(
                          TextSpan( text: "Already have an account? ", style: TextStyle(color: Colors.grey),
                            children: [ TextSpan( text: "Sign In", style: TextStyle( color: Colors.blue ))],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
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