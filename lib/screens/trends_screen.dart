import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class TrendsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double monthlyBudget;
  TrendsScreen({super.key, required this.transactions, required this.monthlyBudget});
  Map<String, Map<String, double>> getMonthlyComparison() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;
    Map<String, Map<String, double>> data = {};

    for (var tx in transactions) {
      if (!tx.isExpense) continue; final category = tx.category;
      data.putIfAbsent(category, () => {"current": 0, "previous": 0});
      if (tx.date.month == currentMonth && tx.date.year == currentYear) {data[category]!["current"] = data[category]!["current"]! + tx.amount;} 
      else if (tx.date.month == previousMonth && tx.date.year == previousYear) {data[category]!["previous"] = data[category]!["previous"]! + tx.amount;}

    }
  return data;
  }
  Map<String, double> getMonthlyTotals() {
    Map<String, double> data = {};
    for (var tx in transactions) {
      if (!tx.isExpense) continue;
      String monthKey = "${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}";
      data[monthKey] = (data[monthKey] ?? 0) + tx.amount;
    }
    return data;
  }
  List<MapEntry<String, double>> getSortedMonthlyData() {
    final data = getMonthlyTotals().entries.toList();
    data.sort((a,b) => a.key.compareTo(b.key)); //this gonna keep it in chronological order
    return data;
  }
  List<BarChartGroupData> buildMonthlyBars() {
    final data = getSortedMonthlyData();
    return List.generate(data.length, (index) {
      final value = data[index].value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: value, color: Colors.cyanAccent, width: 16, borderRadius: BorderRadius.circular(6)),
        ],
      );
    });
  }
  Map<String, double> getCategoryTotals() {
    final Map<String, double> data = {};
    for (var tx in transactions) {
      if (tx.isExpense) {
        data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
      }
    }
    return data;
  }
  double getCurrentMonthSpending() {
    final now = DateTime.now();
    double total = 0;
    for (var tx in transactions) {
      if (!tx.isExpense) continue;
      if (tx.date.month == now.month && tx.date.year == now.year) {total += tx.amount;}
    }
    return total;
  }
  String getPredictionInsight(double monthlyBudget) {
    final now = DateTime.now();
    final daysPassed = now.day;
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final spent = getCurrentMonthSpending();
    if (daysPassed == 0) return "No data yet";
    final avgPerDay = spent / daysPassed;
    final predictedTotal = avgPerDay * totalDays;
    if (monthlyBudget == 0) {return "Predicted spending: £${predictedTotal.toStringAsFixed(0)}";};
    if (predictedTotal > monthlyBudget) {final diff = predictedTotal - monthlyBudget;
      return "You may exceed your budget by £${diff.toStringAsFixed(0)}";
    } else {return "✅ You are within budget. Predicted: £${predictedTotal.toStringAsFixed(0)}";};
  }
  String getSpendingTrendInsight() {
    final now = DateTime.now();
    double thisMonth = 0;
    double lastMonth = 0;
    for (var tx in transactions) {
      if (!tx.isExpense) continue;
      if (tx.date.month == now.month) {thisMonth += tx.amount;} 
      else if (tx.date.month == now.month - 1) {lastMonth += tx.amount;}
    }
    if (lastMonth == 0) return "Not enough data";
    final change = ((thisMonth - lastMonth) / lastMonth) * 100;
    if (change > 0) {return "📈 Spending increased by ${change.toStringAsFixed(0)}%";
    } else {return "📉 Spending decreased by ${change.abs().toStringAsFixed(0)}%";};
  }
  double _getMaxValue(Map<String, Map<String, double>> data) {
    double max = 0;
    for (var category in data.values) {
      if (category["current"]! > max) max = category["current"]!;
      if (category["previous"]! > max) max = category["previous"]!;
    }
    return max + 100;
  }
  List<Color> chartColors = [ Colors.deepPurple, Colors.indigo, Colors.blue, Colors.green, Colors.yellow, Colors.orange,Colors.red ];
  List<PieChartSectionData> buildSections() {
    final data = getCategoryTotals();
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    int index = 0;

    return data.entries.map((entry) {
      final percentage = (entry.value/total)*100;
      final section = PieChartSectionData(
        value: entry.value, title: "${percentage.toStringAsFixed(0)}%", radius: 65, color: chartColors[index % chartColors.length],
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
      index++;
      return section;

    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C2541), // dark blue background
      appBar: AppBar(backgroundColor: Color(0xFF1C2541), title: Text("Trends", style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column( crossAxisAlignment: CrossAxisAlignment.start,
            children: [ const Text("Spending Structure", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height:20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration( color: const Color(0xFF3A506B),borderRadius: BorderRadius.circular(22)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: buildSections(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildLegend(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Color(0xFF3A506B), borderRadius: BorderRadius.circular(22)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Monthly Comparison", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    buildLegendRow(),
                    const SizedBox(height: 20),
                    buildHorizontalComparison(),
                  ],
                ),
              ), 
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF3A506B), borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ Text("Monthly Spending Trend", style: TextStyle( color: Colors.white, fontSize:20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    buildMonthlyTrendChart(),
                  ],
                ),
              ),
             // adding AI insights later if i need it
             // buildAIInsights(monthlyBudget)
            ],
          ),
        ),
      )
    );
  }
  Widget buildLegend() {
    final data = getCategoryTotals();
    final total = data.values.fold(0.0, (sum, item) => sum+item);
    int index = 0;
    return Column(
      children: data.entries.map((entry) {
        final percentage = (entry.value / total) * 100;
        final color = chartColors[index % chartColors.length];
        index++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              SizedBox(width: 10),
              Expanded(child: Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 16))),
              Text("${percentage.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      }).toList(),
    );
  }
  Widget buildLegendRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.circle, color: Colors.blue, size: 10),
        SizedBox(width: 6),
        Text("current month", style: TextStyle(color: Colors.white)),
        SizedBox(width: 20),
        Icon(Icons.circle, color: Colors.purple, size: 10),
        SizedBox(width: 6),
        Text("last month", style: TextStyle(color: Colors.white)),
      ],
    );
  }
  Widget buildHorizontalComparison() {
  final data = getMonthlyComparison();
  double max = 0;
  for (var entry in data.values) {
    if (entry["current"]! > max) max = entry["current"]!;
    if (entry["previous"]! > max) max = entry["previous"]!;
  }

  return Column(
    children: data.entries.map((entry) {
      final category = entry.key;
      final current = entry.value["current"]!;
      final previous = entry.value["previous"]!;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: const TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 8),
            Row( //current month bar
              children: [
                const SizedBox(
                  width: 80,
                  child: Text("Current", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                Expanded(
                  child: Container(height: 12, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: current / max,
                      child: Container(decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(6))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
           
            Row( 
              children: [
                const SizedBox(
                  width: 80,
                  child: Text("Previous", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                Expanded(
                  child: Container(height: 12, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: previous / max,
                      child: Container(decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(6))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList(),
  );
 }
  Widget getMonthTitles(double value, TitleMeta meta) {
    final data = getSortedMonthlyData();
    if (value.toInt() >= data.length) return const SizedBox();
    final raw = data[value.toInt()].key; // "2026-03"
    final parts = raw.split("-");
    final monthNum = int.parse(parts[1]);
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return Text(months[monthNum - 1], style: const TextStyle(color: Colors.white70, fontSize: 12));
  }
  Widget buildMonthlyTrendChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData( barGroups: buildMonthlyBars(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getMonthTitles)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.white10, strokeWidth: 1);
           },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
  Widget buildAIInsights(double monthlyBudget) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF3A506B), borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          Text("AI Insights", style: TextStyle( color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold )),
          SizedBox(height: 12),
          Text(getPredictionInsight(monthlyBudget), style: const TextStyle(color: Colors.white)),
          SizedBox(height: 8),
          Text(getSpendingTrendInsight(), style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
