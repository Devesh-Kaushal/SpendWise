
// screens/expenses_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state.dart';

class ExpensesScreen extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onDeleteExpense;

  ExpensesScreen({
    required this.expenses,
    required this.onDeleteExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(child: EmptyState());
    }

    final sortedExpenses = List<Expense>.from(expenses);
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        return ExpenseCard(
          expense: sortedExpenses[index],
          onDelete: onDeleteExpense,
        );
      },
    );
  }
}
