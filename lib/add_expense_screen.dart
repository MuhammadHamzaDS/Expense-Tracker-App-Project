import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/expense.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'Food';
  bool loading = false;

  final categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      selectedDate = widget.expense!.date;
      selectedCategory = widget.expense!.category;
    }
  }

  Future<void> saveExpense() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => loading = true);

    final expenseData = Expense(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: selectedDate,
      category: selectedCategory,
      notes: _notesController.text.trim(),
    );

    final ref = FirebaseFirestore.instance.collection('expenses');

    if (widget.expense == null) {
      await ref.add(expenseData.toMap(userId));
    } else {
      await ref.doc(widget.expense!.id).update(expenseData.toMap(userId));
    }

    setState(() => loading = false);
    Navigator.pop(context);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _amountController,
              label: 'Amount',
              icon: Icons.attach_money,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _notesController,
              label: 'Notes (optional)',
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
              trailing: TextButton(
                onPressed: pickDate,
                child: const Text('Select Date'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : saveExpense,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.expense == null
                            ? 'Save Expense'
                            : 'Update Expense',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
