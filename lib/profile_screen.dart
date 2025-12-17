// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   void logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.purple, Colors.blue],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // HEADER
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 30),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               children: [
//                 const CircleAvatar(
//                   radius: 45,
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.person, size: 50, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   user?.email ?? "No Email",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 30),

//           // OPTIONS
//           ProfileTile(icon: Icons.dark_mode, title: "Dark Mode", onTap: () {}),
//           ProfileTile(
//             icon: Icons.lock_reset,
//             title: "Reset Expenses",
//             onTap: () {},
//           ),
//           ProfileTile(
//             icon: Icons.info_outline,
//             title: "App Info",
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: "Expense Tracker",
//                 applicationVersion: "1.0.0",
//               );
//             },
//           ),
//           ProfileTile(
//             icon: Icons.logout,
//             title: "Logout",
//             color: Colors.red,
//             onTap: () => logout(context),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =====================
// // Reusable Tile Widget
// // =====================
// class ProfileTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//   final Color color;

//   const ProfileTile({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.onTap,
//     this.color = Colors.black,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: color),
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.w500, color: color),
//       ),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
