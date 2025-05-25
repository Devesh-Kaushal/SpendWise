// screens/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../widgets/premium_expense_card.dart';

class ExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onDeleteExpense;

  ExpensesScreen({
    required this.expenses,
    required this.onDeleteExpense,
  });

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late List<AnimationController> _cardControllers;
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _cardControllers = List.generate(
      widget.expenses.length,
          (index) => AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _listController.forward();
    await Future.delayed(Duration(milliseconds: 200));

    for (int i = 0; i < _cardControllers.length; i++) {
      if (i >= 10) break; // Limit initial animations
      await Future.delayed(Duration(milliseconds: 50));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Expense> get filteredExpenses {
    final now = DateTime.now();
    final sorted = List<Expense>.from(widget.expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));

    switch (selectedFilter) {
      case 'Today':
        return sorted.where((expense) {
          return expense.date.day == now.day &&
              expense.date.month == now.month &&
              expense.date.year == now.year;
        }).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return sorted.where((expense) {
          return expense.date.isAfter(weekStart);
        }).toList();
      case 'This Month':
        return sorted.where((expense) {
          return expense.date.month == now.month &&
              expense.date.year == now.year;
        }).toList();
      default:
        return sorted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  'All Expenses',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                centerTitle: false,
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _listController,
                curve: Curves.easeOutCubic,
              )),
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: filterOptions.length,
                  itemBuilder: (context, index) {
                    final option = filterOptions[index];
                    final isSelected = selectedFilter == option;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedFilter = option;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ) : null,
                          color: isSelected ? null : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Expenses List
          if (filteredExpenses.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final expense = filteredExpenses[index];
                    final controller = index < _cardControllers.length
                        ? _cardControllers[index]
                        : null;

                    if (controller != null) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: controller,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(
                          opacity: controller,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: PremiumExpenseCard(
                              expense: expense,
                              onDelete: widget.onDeleteExpense,
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: PremiumExpenseCard(
                        expense: expense,
                        onDelete: widget.onDeleteExpense,
                      ),
                    );
                  },
                  childCount: filteredExpenses.length,
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            selectedFilter == 'All'
                ? 'Start adding expenses to track your spending'
                : 'No expenses found for the selected time period',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}