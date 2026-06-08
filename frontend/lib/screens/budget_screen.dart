import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final expenses = txProvider.transactions
        .where((t) => t.type == 'expense')
        .toList();

    final Map<String, double> spending = {};
    for (final txn in expenses) {
      final label = txn.description ?? 'Other';
      spending[label] = (spending[label] ?? 0) + txn.amount;
    }

    // Hardcoded sample budgets for demo — replace with real data from backend later
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

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: percentage),
                  const SizedBox(height: 4),
                  Text(
                    '\$${actual.toStringAsFixed(0)} of \$${budget.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.grey),
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
