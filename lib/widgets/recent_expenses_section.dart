
// widgets/recent_expenses_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import 'premium_expense_card.dart';

class RecentExpensesSection extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onDeleteExpense;

  RecentExpensesSection({
    required this.expenses,
    required this.onDeleteExpense,
  });

  @override
  _RecentExpensesSectionState createState() => _RecentExpensesSectionState();
}

class _RecentExpensesSectionState extends State<RecentExpensesSection>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late List<AnimationController> _cardControllers;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    final recentCount = widget.expenses.length.clamp(0, 5);
    _cardControllers = List.generate(recentCount, (index) =>
        AnimationController(
          duration: Duration(milliseconds: 400),
          vsync: this,
        )
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(Duration(milliseconds: 200));

    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(widget.expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-0.5, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _headerController,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (widget.expenses.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Navigate to expenses screen
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Expenses List
        if (recentExpenses.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: recentExpenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;

              if (index < _cardControllers.length) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardControllers[index],
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _cardControllers[index],
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
              return SizedBox.shrink();
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
              Icons.receipt_long_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense\nand start tracking your spending',
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
