// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../widgets/premium_fab.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/premium_expense_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  List<Expense> expenses = [];
  double monthlyBudget = 5000.0;
  int selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
    HapticFeedback.lightImpact();
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
    HapticFeedback.mediumImpact();
  }

  void _updateBudget(double budget) {
    setState(() {
      monthlyBudget = budget;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: [
          DashboardScreen(
            expenses: expenses,
            monthlyBudget: monthlyBudget,
            onUpdateBudget: _updateBudget,
            onDeleteExpense: _deleteExpense,
          ),
          ExpensesScreen(
            expenses: expenses,
            onDeleteExpense: _deleteExpense,
          ),
          AnalyticsScreen(expenses: expenses),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onTabSelected: _onTabSelected,
      ),
      floatingActionButton: selectedIndex < 3 ? PremiumFAB(
        onPressed: () => _showAddExpenseModal(),
        controller: _fabController,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showAddExpenseModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumExpenseForm(
        onAddExpense: _addExpense,
      ),
    );
  }
}