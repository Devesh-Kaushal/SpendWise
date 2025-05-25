
// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/premium_budget_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/recent_expenses_section.dart';
import '../widgets/premium_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double monthlyBudget;
  final Function(double) onUpdateBudget;
  final Function(Expense) onDeleteExpense;

  DashboardScreen({
    required this.expenses,
    required this.monthlyBudget,
    required this.onUpdateBudget,
    required this.onDeleteExpense,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _cardControllers;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardControllers = List.generate(
      4,
          (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    _controller.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double get totalExpenses {
    return widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        PremiumAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Budget Card with Animation
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardControllers[0],
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _cardControllers[0],
                    child: PremiumBudgetCard(
                      monthlyBudget: widget.monthlyBudget,
                      totalExpenses: totalExpenses,
                      onUpdateBudget: widget.onUpdateBudget,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Quick Stats
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardControllers[1],
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _cardControllers[1],
                    child: QuickStatsRow(
                      expenses: widget.expenses,
                      totalExpenses: totalExpenses,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Recent Expenses
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardControllers[2],
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _cardControllers[2],
                    child: RecentExpensesSection(
                      expenses: widget.expenses,
                      onDeleteExpense: widget.onDeleteExpense,
                    ),
                  ),
                ),
                SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }
}
