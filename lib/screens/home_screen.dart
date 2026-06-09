import 'package:flutter/material.dart';
import 'addtransaction_screen.dart'; 
import 'package:flutter_application_1/models/transaction_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'trends_screen.dart';
// home screen (basic version)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Map<String, double> getCategoryTotals() { // calculates total expenses for each category for the current month
    Map<String, double> totals = {};
    for (var tx in transactions) {
      if (tx.isExpense) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }
    return totals;
  }
  final Map<String, IconData> categories = { // category icons
    "General": Icons.category,
    "Food": Icons.fastfood,
    "Transport": Icons.directions_car,
    "Entertainment": Icons.movie,
    "Shopping": Icons.shopping_cart,
    "Bills": Icons.receipt_long,
    "Salary": Icons.attach_money,
    "Investment": Icons.trending_up,
  };
  Future<void> loadBudget() async { //loads budget 
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
    });
  }
  Future<void> saveTransactions() async { //saves transactions
    final prefs = await SharedPreferences.getInstance();
    List<String> txList = transactions.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('transactions', txList);
  }
  Future<void> loadTransactions() async { //loads transactions
    final prefs = await SharedPreferences.getInstance();
    List<String>? txList = prefs.getStringList('transactions');
    if (txList != null) {
      setState(() {
        transactions = txList.map((tx) => TransactionModel.fromJson(jsonDecode(tx))).toList();
        transactions.sort((a, b) => b.date.compareTo(a.date)); // sort by date (newest first)
      });
    }
  }
  Future<void> checkMonthlyReset() async { // checks if it's a new month and resets budget tracker if so
    final prefs = await SharedPreferences.getInstance();
    int currentMonth = DateTime.now().month;
    int? lastResetMonth = prefs.getInt('lastResetMonth');
    if (lastResetMonth == null || lastResetMonth != currentMonth) {
      await prefs.setInt('lastResetMonth', currentMonth);
    }
  }
  
  List<TransactionModel> transactions = [];
  double monthlyBudget = 0;
  double getTotalSavings() {
    double total = 0;
    for (var tx in transactions) {
      if (!tx.isExpense) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }
  double getCurrentMonthExpenses() {
    double total = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }
  double getBudgetProgress() {
    if (monthlyBudget == 0) return 0;
    return getCurrentMonthExpenses() / monthlyBudget;
  }
  List<Widget> _buildTransactionList(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    List<Widget> widgets = [];
    String lastDate = "";
    for (var tx in transactions) {
      String date = DateFormat("dd MMM, yyyy").format(tx.date);
      if (date != lastDate) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              date,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
        lastDate = date;
      }
      widgets.add(
        Dismissible( // delete transaction by swiping left
          key: Key(tx.hashCode.toString()), // unique key for each transaction
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            final scaffold = ScaffoldMessenger.of(context);
            setState(() {
              transactions.remove(tx);
            });
            saveTransactions(); // Save transactions after deletion
            scaffold.showSnackBar( SnackBar(content: Text('Transaction deleted')) );
            loadBudget(); // Reload budget after deletion
          },
          background: Container( 
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                 children: [
                  CircleAvatar( radius: 20, backgroundColor: const Color(0xFF3A506B), child: Icon(categories[tx.category] ?? Icons.category, color: Colors.white)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title, style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text(tx.category, style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              
            
              Text(
                
                "${tx.isExpense ? '- ' : '+ '}$currency${tx.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: tx.isExpense ? Colors.white : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        )
        ),
      );
      Widget buildPieChart() {
        final total = getCategoryTotals();
        return SizedBox(
          height:200,
          child: PieChart(
            PieChartData(
              sections: total.entries.map((entry) {
                return PieChartSectionData(
                  value: entry.value,
                  title: entry.key,
                  color: Colors.primaries[total.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                );
              }).toList(),
            ),
          ),
        );
      }

    }
    return widgets;
  }
  @override
  void initState() {
    super.initState();
    checkMonthlyReset(); // Check for monthly reset on app start
    loadTransactions(); // Load transactions on app start
    loadBudget(); // Load budget on app start
  }
  @override
  Widget build(BuildContext context) {
  final currency = Provider.of<CurrencyProvider>(context).currency; // Get currency from provider

  return Scaffold(
    backgroundColor: Color(0xFF1C2541), // dark blue background
    appBar: AppBar( backgroundColor: Color(0xFF1C2541), elevation: 2, automaticallyImplyLeading: false, // header with title and profile icon
      title: Text("SAVR", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => SettingsScreen())
              );
              if (result == true) {
                await loadBudget(); 
              
                setState(() {}); // Reload budget when returning from settings if it was updated
              } 
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1C2541),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          )
      ],
    ),
      body: SafeArea(
        child: Padding(
         padding: EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             
             Text("Total Savings", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,)),
             SizedBox(height: 8),
             Text("$currency${getTotalSavings().toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), //might remove this later looks kinda ugly
             SizedBox(height: 28),
             // budget box
             Container(
               padding: EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Color(0xFF3A506B), // lighter background for the card
                 borderRadius: BorderRadius.circular(22),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text("Monthly budget allowance", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                       GestureDetector(onTap: () {Navigator.push(context, MaterialPageRoute(
                        builder: (context) => TrendsScreen(transactions: transactions, monthlyBudget: monthlyBudget),));},
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Color(0xFF1C2541), shape: BoxShape.circle, boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2),),
                          ],
                          ),
                          child: const Icon(Icons.bar_chart, color: Colors.white, size: 26),
                        )
                      )
                    ]
                   ),
                   SizedBox(height: 12),
                   Row(
                     children: [
                       Text("$currency${getCurrentMonthExpenses().toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                       Text("/$currency${monthlyBudget.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 18)),
                       Text("${(getBudgetProgress() * 100).toStringAsFixed(0)}% used", style: TextStyle(color: Colors.white, fontSize: 10)),
                     ],
                  ),
                       SizedBox(height:12),
                       ClipRRect(
                         borderRadius: BorderRadius.circular(20),
                         child: LinearProgressIndicator(
                           value: getBudgetProgress().clamp(0.0, 1.0), // progress bar
                           minHeight: 10,
                           backgroundColor: const Color.fromARGB(197, 120, 118, 118),
                           color: const Color.fromARGB(255, 238, 236, 236),
                         ),
                       )
                  ],
                )
              ),

             SizedBox(height: 28),
             // recent transactions
             Expanded( child: Container(
               padding: EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Color(0xFF3A506B),
                 borderRadius: BorderRadius.circular(22),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Recent Transactions", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                       Text("See all", style: TextStyle(color: const Color.fromARGB(255, 23, 143, 255), fontSize: 14)),
                     ],
                   ),
                   Expanded(
                     child: ListView( 
                      children: _buildTransactionList(context) 
                      ),
                    )
                  ],
                )
              ),
              ) 
            ],
          ),
        ),
      ),
                  
      floatingActionButton: FloatingActionButton( //add transaction button '+'
       onPressed: () async {
         final newTransaction = await Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => AddTransactionScreen()),
         );
         if (newTransaction != null && newTransaction is TransactionModel) {
           setState(() {
             transactions.add(newTransaction);
             transactions.sort((a, b) => b.date.compareTo(a.date)); // Sort transactions by date (newest first)
           });
           saveTransactions(); // Save transactions after adding a new one
         }
        
       },
       backgroundColor: const Color.fromARGB(255, 23, 143, 255),
       child: const Icon(Icons.add),
     ),
  );
  }
} 