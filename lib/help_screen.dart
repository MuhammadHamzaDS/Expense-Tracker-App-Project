// import 'package:flutter/material.dart';

// class HelpScreen extends StatelessWidget {
//   const HelpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: Text("Help & Support")));
//   }
// }
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email Support"),
              subtitle: Text("support@expenseapp.com"),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Call Us"),
              subtitle: Text("+92 300 1234567"),
            ),
          ],
        ),
      ),
    );
  }
}
