import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    final expenses = txProvider.transactions
        .where((t) => t.type == 'expense')
        .toList();

    final Map<String, double> spending = {};
    for (final txn in expenses) {
      final label = txn.description ?? 'Other';
      spending[label] = (spending[label] ?? 0) + txn.amount;
    }

    // Hardcoded demo budgets — ideally sourced from backend later
    final Map<String, double> budgets = {
      'Lunch': 200.0,
      'Groceries': 300.0,
      'Transport': 150.0,
      'Coffee': 100.0,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Budget vs Actual')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: budgets.entries.map((entry) {
          final category = entry.key;
          final budget = entry.value;
          final actual = spending[category] ?? 0;
          final percentage = budget > 0 ? (actual / budget).clamp(0.0, 1.0) : 0.0;
          final isOverBudget = actual > budget;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: theme.textTheme.titleMedium),
                      Text(
                        '\$${actual.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade800,
                      color: isOverBudget ? Colors.redAccent : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOverBudget
                        ? 'Over budget by \$${(actual - budget).toStringAsFixed(0)}'
                        : '${(percentage * 100).toStringAsFixed(0)}% used',
                    style: TextStyle(
                      color: isOverBudget ? Colors.redAccent : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
