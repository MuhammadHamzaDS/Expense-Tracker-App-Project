// import 'package:flutter/material.dart';

// class MonthlyReportScreen extends StatelessWidget {
//   const MonthlyReportScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: Text("Monthly Report Screen")));
//   }
// }
import 'package:flutter/material.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Report"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _reportCard("January", 1200),
            _reportCard("February", 950),
            _reportCard("March", 1600),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(String month, double amount) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(month),
        trailing: Text(
          "\$$amount",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
