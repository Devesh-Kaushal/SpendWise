// screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Expense> expenses;

  AnalyticsScreen({required this.expenses});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late List<AnimationController> _cardControllers;
  String selectedPeriod = 'This Month';
  final List<String> periods = ['This Week', 'This Month', 'Last 3 Months'];

  final Map<String, Map<String, dynamic>> categoryData = {
    'Food & Dining': {'icon': Icons.restaurant_rounded, 'color': Color(0xFFFF6B6B)},
    'Transportation': {'icon': Icons.directions_car_rounded, 'color': Color(0xFF4ECDC4)},
    'Books & Supplies': {'icon': Icons.book_rounded, 'color': Color(0xFF45B7D1)},
    'Entertainment': {'icon': Icons.movie_rounded, 'color': Color(0xFF96CEB4)},
    'Shopping': {'icon': Icons.shopping_bag_rounded, 'color': Color(0xFFFECE91)},
    'Bills & Utilities': {'icon': Icons.receipt_rounded, 'color': Color(0xFFF8B195)},
    'Other': {'icon': Icons.category_rounded, 'color': Color(0xFFDDA0DD)},
  };

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardControllers = List.generate(
      7, // Max categories
          (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _chartController.forward();

    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, double> get categoryTotals {
    Map<String, double> totals = {};
    final filteredExpenses = _getFilteredExpenses();

    for (var expense in filteredExpenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();

    switch (selectedPeriod) {
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return widget.expenses.where((expense) {
          return expense.date.isAfter(weekStart);
        }).toList();
      case 'This Month':
        return widget.expenses.where((expense) {
          return expense.date.month == now.month &&
              expense.date.year == now.year;
        }).toList();
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return widget.expenses.where((expense) {
          return expense.date.isAfter(threeMonthsAgo);
        }).toList();
      default:
        return widget.expenses;
    }
  }

  double get totalExpenses {
    return _getFilteredExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
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
                  'Analytics',
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

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Period Filter
                  _buildPeriodFilter(),
                  SizedBox(height: 24),

                  // Total Spending Card
                  _buildTotalSpendingCard(),
                  SizedBox(height: 24),

                  // Category Breakdown Header
                  Row(
                    children: [
                      Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '${categoryTotals.length} categories',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Category List
          if (categoryTotals.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = categoryTotals.keys.elementAt(index);
                    final amount = categoryTotals[category]!;
                    final percentage = (amount / totalExpenses * 100);
                    final categoryInfo = categoryData[category] ??
                        {'icon': Icons.category_rounded, 'color': Color(0xFFDDA0DD)};

                    return index < _cardControllers.length
                        ? SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _cardControllers[index],
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: _cardControllers[index],
                        child: _buildCategoryCard(
                          category, amount, percentage, categoryInfo,
                        ),
                      ),
                    )
                        : _buildCategoryCard(category, amount, percentage, categoryInfo);
                  },
                  childCount: categoryTotals.length,
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

  Widget _buildPeriodFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = selectedPeriod == period;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                selectedPeriod = period;
              });
              _startAnimations();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                period,
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
    );
  }

  Widget _buildTotalSpendingCard() {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spending',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        selectedPeriod,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Transform.scale(
                scale: _chartController.value,
                child: Text(
                  '₹${totalExpenses.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${_getFilteredExpenses().length} transactions',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String category, double amount, double percentage, Map<String, dynamic> categoryInfo) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (categoryInfo['color'] as Color).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: (categoryInfo['color'] as Color).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryInfo['color'] as Color,
                      (categoryInfo['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  categoryInfo['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: categoryInfo['color'] as Color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AnimatedBuilder(
            animation: _chartController,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100) * _chartController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryInfo['color'] as Color,
                          (categoryInfo['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: (categoryInfo['color'] as Color).withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
              Icons.analytics_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No data to analyze',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some expenses to see detailed analytics\nand spending patterns',
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