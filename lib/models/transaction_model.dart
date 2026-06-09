class TransactionModel {
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String category; 
  
  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'category': category,
    };
  }
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      isExpense: json['isExpense'],
      category: json['category'] ?? "General", // default to "General" if category is missing
    );
  }
}