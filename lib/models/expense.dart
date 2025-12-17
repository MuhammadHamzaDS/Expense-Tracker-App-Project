import 'package:cloud_firestore/cloud_firestore.dart'; // ye Timestamp ke liye

class Expense {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? notes;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
  });

  factory Expense.fromMap(Map<String, dynamic> data, String id) {
    return Expense(
      id: id,
      title: data['title'],
      amount: (data['amount']).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'General',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'notes': notes,
      'userId': userId,
    };
  }
}
