import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'signin_screen.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController budgetController = TextEditingController();
  String Name = "User"; // Placeholder for user name, will be extended to load from personal details
  String Email = "example@gmail.com"; // Placeholder for user email, will be extended to load from personal details
  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      budgetController.text = (prefs.getDouble('monthlyBudget') ?? 0).toString();
    });
  }
  Future<void> saveBudget() async {
    final prefs = await SharedPreferences.getInstance();
    double budget = double.tryParse(budgetController.text) ?? 0;
    await prefs.setDouble('monthlyBudget', budget);
    Navigator.pop(context, true); // closes bottom sheet 
    Navigator.pop(context, true); // returns to home screen and triggers reload of budget if it was updated
  }
  Future<void> loadProfile() async {
    // This function will be implemented to load user profile details 
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Name = prefs.getString('UserName') ?? "User";
      Email = prefs.getString('UserEmail') ?? "example@gmail.com";
    });
  }
  Future<void> saveProfile() async { // This function will be implemented to save user profile details 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserName', Name);
    await prefs.setString('UserEmail', Email);
    setState(() {
      Name = Name;
      Email = Email;
    }); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF1C2541),
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1C2541),
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(child: SingleChildScrollView( child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFF3A506B),
              child: Icon(Icons.person, color: Colors.white, size: 55),
            ),
            SizedBox(height: 14),
            Text(Name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(Email, style: TextStyle(color: Colors.white54, fontSize: 14)),
            SizedBox(height: 24),

            _buildSettingOption(context, "Personal Details", Icons.person,
              onTap: () {
                showModalBottomSheet(
                  context: context, backgroundColor: Color(0xFF1C2541), shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  isScrollControlled: true,
                  builder: (context) { // personal deets entering pop up
                    final NameController = TextEditingController(text: Name);
                    final EmailController = TextEditingController(text: Email);
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Personal Details", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          TextField(
                            controller: NameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Name",
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: EmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                Name = NameController.text;
                                Email = EmailController.text;
                              });
                              saveProfile();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3A506B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                          )
                        ]
                      )
                    );
                  },
                );
              },
            ),

            SizedBox(height: 16),
            _buildSettingOption(context, "Currency", Icons.currency_pound,
              onTap: () {
                showModalBottomSheet(context: context, backgroundColor: Color(0xFF1C2541), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ), 
                isScrollControlled: true,
                builder: (context) {
                  List<String> currencies = ["£", "\$", "€", "¥"];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: currencies.map((currency) {
                      return ListTile(
                        title: Text(currency, style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Provider.of<CurrencyProvider>(context, listen: false).setCurrency(currency); // Update currency in provider
                          
                          Navigator.pop(context);
                        },
                      );
                    }).toList()
                  );
                });
              }
            ),
           
              
            SizedBox(height: 16),
            _buildSettingOption(context, "Manage Budget", Icons.account_balance_wallet,
              onTap: () {
                showModalBottomSheet(context: context, backgroundColor: Color(0xFF1C2541), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ), 
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Set Monthly Budget", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        TextField(
                          controller: budgetController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Enter amount",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3A506B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                        )
                      ]
                    )
                  );
                });
              }
            ),
           
              
            SizedBox(height: 16),
            _buildSettingOption(context, "Notifications", Icons.notifications),
            SizedBox(height: 16),
            _buildSettingOption(context, "Security", Icons.security),   
            SizedBox(height: 24),
            _buildSettingOption(context, "Logout", Icons.logout,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SigninScreen()),
                  (route) => false,
                );
              },
            ),
            SizedBox(height: 30),
          ]  
        ) 
      ),
      )
      ),         
    );
  }
  @override
  void initState() {
    super.initState();
    loadBudget();
    loadProfile();
  }
  Widget _buildSettingOption(
    BuildContext context, 
    String title, 
    IconData icon, { 
    VoidCallback? onTap, 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Color(0xFF3A506B), // lighter background for the card
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF1C2541), // darker background for the icon
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
          ]
        )
      )
    );
  }
}

        