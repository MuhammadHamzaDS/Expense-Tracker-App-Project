import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// Note: 'add_expense_screen.dart' and '../../models/expense.dart' were
// removed from the original context, so I implemented a basic inline add/update
// functionality using modal bottom sheet for quick demonstration.
// You should connect the actual AddExpenseScreen if you need full functionality.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ensure the user is logged in before accessing uid
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController(); // Added notes controller

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ================= ADD Expense =================
  Future<void> addExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null) return; // Basic validation

    await FirebaseFirestore.instance.collection('expenses').add({
      'title': titleController.text.trim(),
      'amount': amount,
      'notes': notesController.text.trim(), // Included notes
      'date': Timestamp.now(),
      'userId': userId,
    });

    titleController.clear();
    amountController.clear();
    notesController.clear();
    if (mounted) Navigator.pop(context);
  }

  // ================= UPDATE Expense =================
  void updateExpenseSheet(
    String id,
    String title,
    double amount,
    String? notes,
  ) {
    titleController.text = title;
    amountController.text = amount.toStringAsFixed(2);
    notesController.text = notes ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Update Expense",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration('Title', Icons.text_fields),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Amount (\$)',
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Notes (Optional)',
                    Icons.note_add,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    final newAmount = double.tryParse(amountController.text);
                    if (newAmount == null) return;

                    await FirebaseFirestore.instance
                        .collection('expenses')
                        .doc(id)
                        .update({
                          'title': titleController.text.trim(),
                          'amount': newAmount,
                          'notes': notesController.text.trim(),
                        });

                    titleController.clear();
                    amountController.clear();
                    notesController.clear();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    "Update Expense",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= DELETE Expense =================
  void deleteExpense(String id) async {
    await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense deleted successfully"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= Quick Add UI =================
  void showAddExpenseSheet() {
    titleController.clear();
    amountController.clear();
    notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Add New Expense",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration('Title', Icons.text_fields),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Amount (\$)',
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Notes (Optional)',
                    Icons.note_add,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: addExpense,
                  child: const Text(
                    "Save Expense",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
      ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    final expensesRef = FirebaseFirestore.instance
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        flexibleSpace: Container(
          // Use flexibleSpace for gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: expensesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          double total = 0;
          for (var doc in snapshot.data!.docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SUMMARY CARD =================
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Expenses",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "This Period",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ================= EXPENSE LIST =================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] as num).toDouble();
                    final title = data['title'] as String;
                    final notes = data['notes'] as String?;
                    final date = (data['date'] as Timestamp).toDate();

                    return Dismissible(
                      key: ValueKey(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Deletion"),
                              content: const Text(
                                "Are you sure you want to delete this expense?",
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (_) => deleteExpense(doc.id),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6, // Increased elevation
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: amount > 200
                                ? Colors.redAccent
                                : Colors.deepPurple,
                            radius: 25,
                            child: Text(
                              title[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy – hh:mm a').format(date),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            "\$${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: amount > 200
                                  ? Colors.redAccent
                                  : Colors.green,
                            ),
                          ),
                          children: [
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (notes != null && notes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        "Notes: $notes",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () => updateExpenseSheet(
                                          doc.id,
                                          title,
                                          amount,
                                          notes,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => deleteExpense(doc.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddExpenseSheet,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("New Expense"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ================= MENU SCREEN =================
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of map items updated for more features
    final menuItems = [
      {
        "title": "Reports & Analytics",
        "icon": Icons.pie_chart,
        "screen": const ReportsScreen(),
        "subtitle": "View charts and summaries",
      },
      {
        "title": "Budget Planner",
        "icon": Icons.account_balance_wallet,
        "screen": const BudgetScreen(),
        "subtitle": "Manage your monthly limits",
      },
      {
        "title": "Income Tracker",
        "icon": Icons.attach_money,
        "screen": const IncomeScreen(),
        "subtitle": "Track your earnings",
      },
      {
        "title": "Categories",
        "icon": Icons.category,
        "screen": const CategoriesScreen(),
        "subtitle": "Manage expense types",
      },
      {
        "title": "Profile",
        "icon": Icons.person,
        "screen": const ProfileScreen(),
        "subtitle": "Manage account information",
      },
      {
        "title": "Notifications",
        "icon": Icons.notifications_active,
        "screen": const NotificationsScreen(),
        "subtitle": "View alerts and reminders",
      },
      {
        "title": "Settings",
        "icon": Icons.settings,
        "screen": const SettingsScreen(),
        "subtitle": "Configure application settings",
      },
      {
        "title": "Help & Support",
        "icon": Icons.help_center,
        "screen": SupportScreen(),
        "subtitle": "Get assistance and guides",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Navigation Menu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: Colors.deepPurple,
                  size: 28,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.deepPurple,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ================= PLACEHOLDER SCREENS =================

// ================= REPORTS SCREEN (Example of a rich screen) =================
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // Dummy data structure for demonstration
  final List<ExpenseCategory> data = const [
    ExpenseCategory('Food', 200, Colors.deepPurple),
    ExpenseCategory('Transport', 100, Colors.purpleAccent),
    ExpenseCategory('Entertainment', 150, Colors.pink),
    ExpenseCategory('Shopping', 250, Colors.orange),
    ExpenseCategory('Bills', 120, Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    double total = data.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reports & Analytics",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Expenses Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Expenses for the Month",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Category Breakdown Title
            const Text(
              "Category Breakdown",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Category-wise Expenses List
            ...data.map((item) {
              final percentage = (item.amount / total) * 100;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.color,
                    radius: 20,
                    child: Text(
                      item.category[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    item.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${percentage.toStringAsFixed(1)}% of total"),
                  trailing: Text(
                    "\$${item.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action to view detailed report
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("View Detailed Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DUMMY MODEL =================
class ExpenseCategory {
  final String category;
  final double amount;
  final Color color;
  const ExpenseCategory(this.category, this.amount, this.color);
}

// ================= GENERIC PLACEHOLDER SCREEN =================
class DummyScreen extends StatelessWidget {
  final String title;
  final Color color;
  const DummyScreen({
    super.key,
    required this.title,
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: color.withOpacity(0.7)),
              const SizedBox(height: 20),
              Text(
                "$title Screen",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "(Feature Coming Soon!)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= OTHER PLACEHOLDER SCREENS =================

// ================= BUDGET CATEGORY MODEL =================
// यह मॉडल Budget planner के लिए डमी डेटा को परिभाषित करता है
class BudgetCategory {
  final String name;
  final double limit;
  final double spent;
  final Color color;

  const BudgetCategory(this.name, this.limit, this.spent, this.color);

  double get remaining => limit - spent;
  double get percentageSpent => (spent / limit) * 100;
  bool get isOverBudget => spent > limit;
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // डमी बजट डेटा
  final List<BudgetCategory> budgets = [
    const BudgetCategory('Food & Groceries', 500, 350, Colors.deepPurple),
    const BudgetCategory(
      'Transportation',
      150,
      180,
      Colors.redAccent,
    ), // Over budget
    const BudgetCategory('Entertainment', 200, 80, Colors.blueAccent),
    const BudgetCategory('Utilities', 300, 295, Colors.orangeAccent),
    const BudgetCategory('Shopping', 100, 10, Colors.green),
  ];

  // Budget Add/Edit के लिए टेक्स्ट कंट्रोलर (Dummy)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    limitController.dispose();
    super.dispose();
  }

  // बजट मैनेज करने के लिए बॉटम शीट UI
  void showBudgetManagementSheet({BudgetCategory? budget}) {
    if (budget != null) {
      nameController.text = budget.name;
      limitController.text = budget.limit.toStringAsFixed(2);
    } else {
      nameController.clear();
      limitController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  budget == null
                      ? "Add New Budget"
                      : "Edit Budget: ${budget.name}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration('Category Name', Icons.category),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Monthly Limit (\$)',
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // Logic to save/update budget (Firebase integration needed here)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${budget == null ? 'Added' : 'Updated'} budget for ${nameController.text}",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(
                    budget == null ? "Save Budget" : "Update Budget",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Custom Input Decoration for consistency
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalLimit = budgets.fold(0, (sum, b) => sum + b.limit);
    final double totalSpent = budgets.fold(0, (sum, b) => sum + b.spent);
    final double overallRemaining = totalLimit - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Budget Planner",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= MONTHLY SUMMARY CARD =================
            _buildSummaryCard(totalLimit, totalSpent, overallRemaining),

            const SizedBox(height: 25),

            // ================= ACTIONS =================
            _buildActionButtons(),

            const SizedBox(height: 25),

            // ================= BUDGET LIST TITLE =================
            const Text(
              "Category Budgets",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ================= BUDGET CATEGORY LIST =================
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                return _buildBudgetTile(budgets[index]);
              },
            ),
          ],
        ),
      ),
      // Floating Action Button for quick add
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBudgetManagementSheet(),
        icon: const Icon(Icons.add),
        label: const Text("Add New Budget"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Summary Card Widget
  Widget _buildSummaryCard(
    double totalLimit,
    double totalSpent,
    double overallRemaining,
  ) {
    Color cardColor = overallRemaining.isNegative
        ? Colors.red.shade900
        : Colors.green.shade900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Budget Overview",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(
                label: "Total Limit",
                amount: totalLimit,
                color: Colors.white,
              ),
              _summaryItem(
                label: "Spent",
                amount: totalSpent,
                color: Colors.orange.shade200,
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 30),
          Center(
            child: Column(
              children: [
                Text(
                  overallRemaining.isNegative ? "OVER BUDGET" : "Remaining",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${overallRemaining.abs().toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Summary Item Helper Widget
  Widget _summaryItem({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Action Buttons Widget
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.refresh,
            label: "Reset Budgets",
            color: Colors.blueGrey,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _actionButton(
            icon: Icons.analytics,
            label: "View Report",
            color: Colors.teal,
            onTap: () {
              // Navigate to Reports Screen
            },
          ),
        ),
      ],
    );
  }

  // Action Button Helper Widget
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Budget Category Tile Widget
  Widget _buildBudgetTile(BudgetCategory budget) {
    final double percentage = budget.percentageSpent / 100;

    // Budget health color logic
    Color indicatorColor;
    if (budget.isOverBudget) {
      indicatorColor = Colors.red;
    } else if (percentage > 0.8) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: budget.isOverBudget ? Colors.redAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: budget.color.withOpacity(0.1),
          radius: 25,
          child: Icon(Icons.receipt_long, color: budget.color),
        ),
        title: Text(
          budget.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage.clamp(
                  0.0,
                  1.0,
                ), // Limit value for visualization
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Limit: \$${budget.limit.toStringAsFixed(2)} | Spent: \$${budget.spent.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 3),
            Text(
              budget.isOverBudget
                  ? "Over budget by: \$${budget.remaining.abs().toStringAsFixed(2)}"
                  : "Remaining: \$${budget.remaining.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: indicatorColor,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () => showBudgetManagementSheet(budget: budget),
        ),
      ),
    );
  }
}

// Dummy Screen for navigation (from previous response)
class DummyScreens extends StatelessWidget {
  final String title;
  final Color color;
  const DummyScreens({
    super.key,
    required this.title,
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "$title Screen",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// INCome Screen

// ================= INCOME ENTRY MODEL (Dummy Data) =================
class IncomeEntry {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String? notes;

  const IncomeEntry({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.notes,
  });
}

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  // डमी आय डेटा
  List<IncomeEntry> incomeEntries = [
    IncomeEntry(
      id: '1',
      source: 'Monthly Salary',
      amount: 3500.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    IncomeEntry(
      id: '2',
      source: 'Freelance Project',
      amount: 850.50,
      date: DateTime.now().subtract(const Duration(days: 12)),
      notes: "Project Alpha completion.",
    ),
    IncomeEntry(
      id: '3',
      source: 'Investment Dividend',
      amount: 120.00,
      date: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  final TextEditingController sourceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    sourceController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ================= INCOME LOGIC (Dummy) =================
  void addOrUpdateIncome(IncomeEntry? oldEntry) {
    // Placeholder logic for adding/updating
    final source = sourceController.text.trim();
    final amount = double.tryParse(amountController.text);
    final notes = notesController.text.trim();

    if (source.isEmpty || amount == null) return;

    if (oldEntry == null) {
      // Add new
      final newEntry = IncomeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        source: source,
        amount: amount,
        date: DateTime.now(),
        notes: notes,
      );
      setState(() {
        incomeEntries.add(newEntry);
      });
    } else {
      // Update existing (In a real app, you would update Firestore here)
      final index = incomeEntries.indexWhere((e) => e.id == oldEntry.id);
      if (index != -1) {
        setState(() {
          incomeEntries[index] = IncomeEntry(
            id: oldEntry.id,
            source: source,
            amount: amount,
            date: oldEntry.date,
            notes: notes,
          );
        });
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Income ${oldEntry == null ? 'added' : 'updated'} successfully.",
        ),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  void deleteIncome(String id) {
    // Placeholder logic for deletion (In a real app, you would delete from Firestore)
    setState(() {
      incomeEntries.removeWhere((entry) => entry.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Income entry deleted."),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================= UI HELPERS =================
  void showIncomeManagementSheet({IncomeEntry? entry}) {
    sourceController.text = entry?.source ?? '';
    amountController.text = entry?.amount.toStringAsFixed(2) ?? '';
    notesController.text = entry?.notes ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  entry == null ? "Record New Income" : "Edit Income Source",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: sourceController,
                  decoration: _inputDecoration(
                    'Income Source (e.g., Salary, Gift)',
                    Icons.work,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Amount Received (\$)',
                    Icons.monetization_on,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Notes (Optional)',
                    Icons.note_add,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => addOrUpdateIncome(entry),
                  child: Text(
                    entry == null ? "Save Income" : "Update Income",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.indigo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalIncome = incomeEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Income Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo,
                Colors.blueAccent,
              ], // Blue/Indigo theme for Income
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= MONTHLY INCOME SUMMARY CARD =================
            _buildSummaryCard(totalIncome),

            const SizedBox(height: 25),

            // ================= QUICK ACTIONS =================
            _buildActionButtons(),

            const SizedBox(height: 25),

            // ================= RECENT INCOME TITLE =================
            const Text(
              "Recent Income Entries",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ================= INCOME LIST =================
            incomeEntries.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "No income recorded yet. Tap '+' to add your first income.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeEntries.length,
                    itemBuilder: (context, index) {
                      return _buildIncomeTile(incomeEntries[index]);
                    },
                  ),
          ],
        ),
      ),
      // Floating Action Button for quick add
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIncomeManagementSheet(),
        icon: const Icon(Icons.add),
        label: const Text("Record Income"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Summary Card Widget
  Widget _buildSummaryCard(double totalIncome) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Income This Period",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${totalIncome.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white54, height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Goal Status: On Track",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.check_circle, color: Colors.lightGreen),
            ],
          ),
        ],
      ),
    );
  }

  // Action Buttons Widget
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.calendar_month,
            label: "Monthly View",
            color: Colors.blueGrey,
            onTap: () {
              // Navigate to Monthly Income View
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _actionButton(
            icon: Icons.bar_chart,
            label: "Income Report",
            color: Colors.teal,
            onTap: () {
              // Navigate to Income Report Screen
            },
          ),
        ),
      ],
    );
  }

  // Action Button Helper Widget
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Income Entry Tile Widget
  Widget _buildIncomeTile(IncomeEntry entry) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
      ),
      onDismissed: (_) => deleteIncome(entry.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.withOpacity(0.1),
            radius: 25,
            child: const Icon(Icons.trending_up, color: Colors.indigo),
          ),
          title: Text(
            entry.source,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(entry.date),
                style: const TextStyle(color: Colors.grey),
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Note: ${entry.notes}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "+\$${entry.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => showIncomeManagementSheet(entry: entry),
                child: const Icon(
                  Icons.edit,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Note: You must integrate the IncomeScreen with your MenuScreen navigation.

// ================= CATEGORY MODEL (Dummy Data) =================
class ExpenseCategoryModel {
  final String id;
  String name;
  IconData icon;
  Color color;
  int transactionCount; // How many expenses belong to this category

  ExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.transactionCount = 0,
  });
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // डमी डेटा
  List<ExpenseCategoryModel> categories = [
    ExpenseCategoryModel(
      id: '1',
      name: 'Food & Dining',
      icon: Icons.fastfood,
      color: Colors.red,
      transactionCount: 15,
    ),
    ExpenseCategoryModel(
      id: '2',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      transactionCount: 8,
    ),
    ExpenseCategoryModel(
      id: '3',
      name: 'Bills & Utilities',
      icon: Icons.lightbulb,
      color: Colors.amber.shade800,
      transactionCount: 5,
    ),
    ExpenseCategoryModel(
      id: '4',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.green,
      transactionCount: 12,
    ),
    ExpenseCategoryModel(
      id: '5',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      transactionCount: 20,
    ),
  ];

  final TextEditingController nameController = TextEditingController();
  IconData selectedIcon = Icons.category;
  Color selectedColor = Colors.deepPurple;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // ================= UI HELPERS =================

  void showCategoryManagementSheet({ExpenseCategoryModel? category}) {
    nameController.text = category?.name ?? '';
    selectedIcon = category?.icon ?? Icons.category;
    selectedColor = category?.color ?? Colors.deepPurple;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSetter) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      category == null ? "Add New Category" : "Edit Category",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration(
                        'Category Name',
                        selectedIcon,
                        selectedColor,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Icon Picker (Dummy implementation for heavy UI) ---
                    _buildIconPicker(setStateSetter),
                    const SizedBox(height: 15),

                    // --- Color Picker (Dummy implementation for heavy UI) ---
                    _buildColorPicker(setStateSetter),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        _saveCategory(category);
                      },
                      child: Text(
                        category == null ? "Save Category" : "Update Category",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
      ),
    );
  }

  // --- Icon Picker Widget ---
  Widget _buildIconPicker(StateSetter setStateSetter) {
    const List<IconData> availableIcons = [
      Icons.fastfood,
      Icons.directions_car,
      Icons.lightbulb,
      Icons.movie,
      Icons.shopping_bag,
      Icons.home,
      Icons.laptop,
      Icons.school,
      Icons.fitness_center,
      Icons.local_hospital,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Icon:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableIcons.map((icon) {
            return GestureDetector(
              onTap: () => setStateSetter(() => selectedIcon = icon),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedIcon == icon
                      ? selectedColor.withOpacity(0.3)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedIcon == icon
                        ? selectedColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: selectedColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Color Picker Widget ---
  Widget _buildColorPicker(StateSetter setStateSetter) {
    const List<Color> availableColors = [
      Colors.deepPurple,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Color:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableColors.map((color) {
            return GestureDetector(
              onTap: () => setStateSetter(() => selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveCategory(ExpenseCategoryModel? oldCategory) {
    if (nameController.text.isEmpty) return;

    if (oldCategory == null) {
      // Add new category
      final newCategory = ExpenseCategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        icon: selectedIcon,
        color: selectedColor,
      );
      setState(() => categories.add(newCategory));
    } else {
      // Update existing category
      setState(() {
        oldCategory.name = nameController.text.trim();
        oldCategory.icon = selectedIcon;
        oldCategory.color = selectedColor;
      });
    }
    Navigator.pop(context);
  }

  void _deleteCategory(String id) {
    // In a real app, you would check if the category is in use before deleting
    setState(() {
      categories.removeWhere((cat) => cat.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Category deleted"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Categories",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUMMARY CARD =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Active Categories",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    categories.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ================= CATEGORY LIST =================
            const Text(
              "Custom Expense Types",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.15),
                      radius: 25,
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(
                      "${category.transactionCount} transactions recorded",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () =>
                              showCategoryManagementSheet(category: category),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryManagementSheet(),
        icon: const Icon(Icons.add),
        label: const Text("Add Category"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // डमी यूजर डेटा
  final String userName = "Vivek Sharma";
  final String userEmail = "vivek.s@expensetracker.com";
  final double totalExpense = 1545.50;
  final double totalIncome = 4470.50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to Settings Screen (Dummy action)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ================= PROFILE INFO CARD =================
            _buildProfileInfoCard(context),
            const SizedBox(height: 30),

            // ================= STATISTICS CARD =================
            _buildStatisticsCard(),
            const SizedBox(height: 30),

            // ================= ACCOUNT ACTIONS =================
            _buildAccountActions(context),
          ],
        ),
      ),
    );
  }

  // Profile Info Card Widget
  Widget _buildProfileInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(
              Icons.person_outline,
              size: 50,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            userEmail,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              // Action to edit profile details (Dummy action)
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Statistics Card Widget
  Widget _buildStatisticsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Financial Overview (All Time)",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            // Note: Colors.redAccent is a MaterialAccentColor, not a MaterialColor,
            // so we use Colors.red.shade700 for depth.
            _statItem(
              title: "Total Expenses",
              amount: totalExpense,
              icon: Icons.money_off,
              // F IXED: Using MaterialColor with explicit shade
              baseColor: Colors.red,
              colorShade: Colors.red.shade700,
            ),
            const SizedBox(width: 15),
            _statItem(
              title: "Total Income",
              amount: totalIncome,
              icon: Icons.attach_money,
              // F IXED: Using MaterialColor with explicit shade
              baseColor: Colors.green,
              colorShade: Colors.green.shade700,
            ),
          ],
        ),
      ],
    );
  }

  // Single Statistic Item - Adjusted for the shade fix
  Widget _statItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color baseColor,
    required Color colorShade,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: baseColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: baseColor, size: 30),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: baseColor, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // FIX: Using the predefined colorShade which is safe
                color: colorShade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Account Actions Widget
  Widget _buildAccountActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Account Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.security, color: Colors.deepPurple),
          title: const Text("Change Password"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Change Password Screen (Dummy action)
          },
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.cloud_download, color: Colors.blue),
          title: const Text("Backup Data"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Initiate data backup (Dummy action)
          },
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // Perform Logout (Dummy action)
          },
        ),
      ],
    );
  }
}

// ================= NOTIFICATION MODEL (Dummy Data) =================
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final Color color;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.color,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // डमी सूचना डेटा
  List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'Budget Alert: Transport',
      body: 'You have exceeded 90% of your transport budget.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      icon: Icons.warning,
      color: Colors.orange,
    ),
    AppNotification(
      id: 'n2',
      title: 'Bill Reminder: Electricity',
      body: 'Your electricity bill payment is due tomorrow.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      icon: Icons.flash_on,
      color: Colors.blue,
    ),
    AppNotification(
      id: 'n3',
      title: 'Weekly Report Ready',
      body: 'Your weekly financial summary is available for review.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.bar_chart,
      color: Colors.green,
    ),
    AppNotification(
      id: 'n4',
      title: 'New Feature Available',
      body: 'Try out the new Income Goals feature!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.campaign,
      color: Colors.deepPurple,
    ),
  ];

  void markAllAsRead() {
    setState(() {
      notifications = notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timestamp: n.timestamp,
          isRead: true,
          icon: n.icon,
          color: n.color,
        );
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read")),
    );
  }

  void markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !notifications[index].isRead) {
        final n = notifications[index];
        notifications[index] = AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timestamp: n.timestamp,
          isRead: true,
          icon: n.icon,
          color: n.color,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to Settings Screen (Notification Settings)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ================= SUMMARY CARD =================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade700,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unreadCount > 0
                      ? "Unread Notifications"
                      : "You're All Caught Up!",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= MARK AS READ ACTION =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: unreadCount > 0 ? markAllAsRead : null,
                icon: Icon(
                  Icons.done_all,
                  color: unreadCount > 0 ? Colors.blue : Colors.grey,
                ),
                label: Text(
                  "Mark all as read",
                  style: TextStyle(
                    color: unreadCount > 0 ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ================= NOTIFICATIONS LIST =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: n.isRead ? 2 : 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: n.isRead ? Colors.transparent : n.color,
                      width: n.isRead ? 0 : 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: n.color.withOpacity(0.15),
                      radius: 25,
                      child: Icon(n.icon, color: n.color),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: n.isRead ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: TextStyle(
                            color: n.isRead ? Colors.grey : Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(n.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    trailing: n.isRead
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => markAsRead(n.id),
                          ),
                    onTap: () => markAsRead(n.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // डमी सेटिंग्स स्टेट
  bool isPushNotificationsEnabled = true;
  bool isBiometricEnabled = false;
  bool isDarkModeEnabled = false;
  String currency = 'USD (\$)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "App Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= GENERAL SETTINGS =================
          _buildSettingsGroup(
            context,
            title: "General",
            children: [
              _buildSimpleTile(
                icon: Icons.language,
                title: "Language",
                subtitle: "English (US)",
                onTap: () {},
              ),
              _buildSimpleTile(
                icon: Icons.attach_money,
                title: "Primary Currency",
                subtitle: currency,
                onTap: () {
                  // Dummy currency selection logic
                  setState(
                    () => currency = (currency == 'USD (\$)')
                        ? 'INR (₹)'
                        : 'USD (\$)',
                  );
                },
              ),
              _buildToggleTile(
                icon: Icons.dark_mode,
                title: "Dark Mode",
                value: isDarkModeEnabled,
                onChanged: (value) {
                  setState(() => isDarkModeEnabled = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ================= NOTIFICATIONS & REMINDERS =================
          _buildSettingsGroup(
            context,
            title: "Notifications & Alerts",
            children: [
              _buildToggleTile(
                icon: Icons.notifications_active,
                title: "Enable Push Notifications",
                value: isPushNotificationsEnabled,
                onChanged: (value) {
                  setState(() => isPushNotificationsEnabled = value);
                },
              ),
              _buildSimpleTile(
                icon: Icons.schedule,
                title: "Set Reminder Time",
                subtitle: "Daily at 8:00 PM",
                onTap: () {},
              ),
              _buildSimpleTile(
                icon: Icons.calendar_today,
                title: "Budget Alert Threshold",
                subtitle: "Alert at 80% usage",
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ================= SECURITY =================
          _buildSettingsGroup(
            context,
            title: "Security & Data",
            children: [
              _buildToggleTile(
                icon: Icons.fingerprint,
                title: "Enable Biometric Lock",
                value: isBiometricEnabled,
                onChanged: (value) {
                  setState(() => isBiometricEnabled = value);
                },
              ),
              _buildSimpleTile(
                icon: Icons.password,
                title: "Change Password",
                onTap: () {},
              ),
              _buildSimpleTile(
                icon: Icons.cloud_upload,
                title: "Data Backup",
                subtitle: "Last backup: Today",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget for Settings Grouping
  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: children
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: item,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Simple Settings Tile
  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Helper Widget for Toggle Settings Tile
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.purpleAccent,
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // डमी FAQ डेटा
  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I add a new expense category?',
      'answer':
          'Go to the Categories screen, tap the "Add Category" button, enter the name, choose an icon and color, and save.',
    },
    {
      'question': 'How can I reset my monthly budget?',
      'answer':
          'On the Budget Planner screen, tap the "Reset Budgets" action button. This will clear the current spending progress but keep your limits saved.',
    },
    {
      'question': 'What data is stored in the cloud?',
      'answer':
          'All your transaction history, categories, budgets, and user settings are securely stored in the cloud (e.g., Firebase/Backend) for access across devices.',
    },
    {
      'question': 'I forgot my password. How to recover?',
      'answer':
          'Use the "Forgot Password" link on the login screen. A recovery link will be sent to your registered email address.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // Consistent purple theme
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER CARD / Contact =================
            _buildContactCard(context),
            const SizedBox(height: 30),

            // ================= QUICK LINKS / ACTIONS =================
            _buildQuickLinks(),
            const SizedBox(height: 30),

            // ================= FAQ SECTION =================
            const Text(
              "Frequently Asked Questions (FAQs)",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            _buildFaqList(),
            const SizedBox(height: 30),

            // ================= LEGAL LINKS =================
            _buildLegalLinks(),
          ],
        ),
      ),
    );
  }

  // --- 1. Contact Card ---
  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text(
            "Need immediate assistance?",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            "Contact Support Team",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              // Action: Open email client or support chat window
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening Support Chat...")),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Start Live Chat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Quick Links ---
  Widget _buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _quickActionButton(
              icon: Icons.bug_report,
              label: "Report a Bug",
              color: Colors.redAccent,
              onTap: () {},
            ),
            _quickActionButton(
              icon: Icons.lightbulb_outline,
              label: "Suggest Feature",
              color: Colors.amber.shade700,
              onTap: () {},
            ),
            _quickActionButton(
              icon: Icons.rate_review,
              label: "Rate Our App",
              color: Colors.green,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget for Quick Action Buttons
  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 100, // Fixed width for symmetry
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. FAQ List ---
  Widget _buildFaqList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
            title: Text(
              faq['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 4. Legal Links ---
  Widget _buildLegalLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Legal Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.policy, color: Colors.grey),
          title: const Text("Privacy Policy"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.article, color: Colors.grey),
          title: const Text("Terms of Service"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "Expense Tracker v1.0.0",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const DummyScreen(title: "About App");
}
