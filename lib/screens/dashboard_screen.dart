
// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/budget_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state.dart';

class DashboardScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double monthlyBudget;
  final Function(double) onUpdateBudget;
  final Function(Expense) onDeleteExpense;
  final VoidCallback onNavigateToExpenses;

  DashboardScreen({
    required this.expenses,
    required this.monthlyBudget,
    required this.onUpdateBudget,
    required this.onDeleteExpense,
    required this.onNavigateToExpenses,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get totalExpenses {
    return widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(widget.expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Track your expenses',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Budget Overview Card
            BudgetCard(
              monthlyBudget: widget.monthlyBudget,
              totalExpenses: totalExpenses,
              onUpdateBudget: widget.onUpdateBudget,
            ),
            SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    title: 'Total Spent',
                    value: '₹${totalExpenses.toStringAsFixed(0)}',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.receipt_long,
                    title: 'Transactions',
                    value: '${widget.expenses.length}',
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    title: 'Daily Avg',
                    value: '₹${(totalExpenses / 30).toStringAsFixed(0)}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Recent Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (widget.expenses.isNotEmpty)
                  TextButton(
                    onPressed: widget.onNavigateToExpenses,
                    child: Text('View All'),
                  ),
              ],
            ),
            SizedBox(height: 12),
            recentExpenses.isEmpty
                ? EmptyState()
                : Column(
              children: recentExpenses
                  .map((expense) => ExpenseCard(
                expense: expense,
                onDelete: widget.onDeleteExpense,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
