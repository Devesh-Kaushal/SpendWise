// utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> categories = [
    'Food & Dining',
    'Transportation',
    'Books & Supplies',
    'Entertainment',
    'Shopping',
    'Bills & Utilities',
    'Other'
  ];

  static const Map<String, Map<String, dynamic>> categoryData = {
    'Food & Dining': {'icon': Icons.restaurant, 'color': Colors.orange},
    'Transportation': {'icon': Icons.directions_bus, 'color': Colors.blue},
    'Books & Supplies': {'icon': Icons.book, 'color': Colors.green},
    'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
    'Shopping': {'icon': Icons.shopping_bag, 'color': Colors.pink},
    'Bills & Utilities': {'icon': Icons.receipt, 'color': Colors.red},
    'Other': {'icon': Icons.category, 'color': Colors.grey},
  };
}
