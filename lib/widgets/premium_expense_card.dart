
// widgets/premium_expense_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';

class PremiumExpenseCard extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onDelete;

  PremiumExpenseCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  _PremiumExpenseCardState createState() => _PremiumExpenseCardState();
}

class _PremiumExpenseCardState extends State<PremiumExpenseCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

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
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = categoryData[widget.expense.category] ??
        {'icon': Icons.category_rounded, 'color': Color(0xFFDDA0DD)};

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _hoverController.forward();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            onLongPress: () => _showDeleteDialog(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
                border: Border.all(
                  color: (categoryInfo['color'] as Color).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Category Icon
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
                        boxShadow: [
                          BoxShadow(
                            color: (categoryInfo['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        categoryInfo['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),

                    // Expense Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.expense.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.expense.category,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.expense.description.isNotEmpty) ...[
                            SizedBox(height: 2),
                            Text(
                              widget.expense.description,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Amount and Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${widget.expense.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDate(widget.expense.date),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    return '${date.day}/${date.month}';
  }

  void _showDeleteDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${widget.expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(widget.expense);
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}