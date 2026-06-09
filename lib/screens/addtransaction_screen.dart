import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
// add transaction screen 

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedCategory = "General"; // default category
  bool _isExpense = true; // default to expense
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  final List<Map<String, dynamic>> categories = [ // categories for dropdown
    {'name': 'General', 'icon': Icons.category},
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt_long},
    {'name': 'Salary', 'icon': Icons.attach_money},
    {'name': 'Investment', 'icon': Icons.trending_up},
  ];

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency; // Get currency from provider
    return Scaffold(
      backgroundColor: Color(0xFF1C2541), // dark background color
      appBar: AppBar(
        backgroundColor: Color(0xFF1C2541),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Add Transaction", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea( child: SingleChildScrollView( // allows scrolling when keyboard is open
        child: Padding( 
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column( //expese and income toggle
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {_isExpense = true;});
                  },
                  child: Column(
                    children: [
                      Text("Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      if (_isExpense) Container(height: 2, width: 60, color: Colors.white)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {_isExpense = false;});
                  },
                  child: Column(
                    children: [
                      Text("Income", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      if (!_isExpense) Container(height: 2, width: 60, color: Colors.white)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Container(// amount input
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFF3A506B), // lighter background for the card
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                Text("$currency", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 28, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),)
              ],)
            ),
            SizedBox(height: 20),
            GestureDetector( onTap: () {
              showModalBottomSheet(
                context: context, backgroundColor: const Color(0xFF3A506B), builder: (context) {
                  return ListView(
                    children: categories.map((cat) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 23, 143, 255),
                          child: Icon(cat['icon'], color: Colors.white),
                        ),
                        title: Text(cat['name'], style: TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() {
                            selectedCategory = cat['name'];
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
            child: Container(// selecting category 
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF3A506B), // lighter background for the card
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 23, 143, 255),
                        child: Icon(Icons.category, color: Colors.white),
                      ),
                      SizedBox(width: 15),
                      Text(selectedCategory, style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  )
                ]
              )
            )),
            SizedBox(height: 20),
            GestureDetector( onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Container(   // selecting date
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF3A506B), // lighter background for the card
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 23, 143, 255),
                        child: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      SizedBox(width: 15),
                      Text(DateFormat("dd MMM, yyyy").format(selectedDate), style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  )
                ]
              )
            )),
            SizedBox(height: 20),
            Container(// adding note
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF3A506B), // lighter background for the card
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 23, 143, 255),
                    child: Icon(Icons.note, color: Colors.white),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Add a note (optional)",
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                ],
              )
            ),
            SizedBox(height: 30),
            GestureDetector( onTap: () { // Handle save transaction logic here
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                // Show error if amount is not valid
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid amount")));
                return;
              }
              final newTransaction = TransactionModel(
                title: noteController.text.isEmpty ? "No Note" : noteController.text,
                amount: amount,
                date: selectedDate,
                isExpense: _isExpense,
                category: selectedCategory,
              );
              Navigator.pop(context, newTransaction); // Return the new transaction to the previous screen
            },
             child: Container(//save button
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 23, 143, 255),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text("Add Transaction", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            ),
          ],
          ),
        ),
    )
    ));
  }
  @override
  void initState() {
    super.initState();
  }
}
