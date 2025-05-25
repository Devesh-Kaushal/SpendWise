
// models/expense.dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String? imageUrl;
  final bool isRecurring;
  final List<String> tags;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
    this.imageUrl,
    this.isRecurring = false,
    this.tags = const [],
  });
}
