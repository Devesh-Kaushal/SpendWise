
// widgets/quick_stats_row.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';

class QuickStatsRow extends StatefulWidget {
  final List<Expense> expenses;
  final double totalExpenses;

  QuickStatsRow({
    required this.expenses,
    required this.totalExpenses,
  });

  @override
  _QuickStatsRowState createState() => _QuickStatsRowState();
}

class _QuickStatsRowState extends State<QuickStatsRow>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) =>
        AnimationController(
          duration: Duration(milliseconds: 600),
          vsync: this,
        )
    );

    _slideAnimations = _controllers.map((controller) =>
        Tween<double>(begin: 50.0, end: 0.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)
        )
    ).toList();

    _fadeAnimations = _controllers.map((controller) =>
        Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeIn)
        )
    ).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 150));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            0,
            'Total Spent',
            '₹${widget.totalExpenses.toStringAsFixed(0)}',
            Icons.trending_up_rounded,
            Color(0xFF00B894),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            1,
            'Transactions',
            '${widget.expenses.length}',
            Icons.receipt_long_rounded,
            Color(0xFF6C5CE7),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            2,
            'Daily Avg',
            '₹${(widget.totalExpenses / 30).toStringAsFixed(0)}',
            Icons.calendar_today_rounded,
            Color(0xFFFF7675),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(int index, String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimations[index], _fadeAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimations[index].value),
          child: Opacity(
            opacity: _fadeAnimations[index].value,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
