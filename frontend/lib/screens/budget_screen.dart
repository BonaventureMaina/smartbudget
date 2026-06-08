import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    // Aggregate all expenses by description
    final Map<String, double> spending = {};
    double totalSpent = 0;
    for (final txn in txProvider.transactions) {
      if (txn.type == 'expense') {
        final label = (txn.description ?? 'Other').trim();
        if (label.isEmpty) continue;
        spending[label] = (spending[label] ?? 0) + txn.amount;
        totalSpent += txn.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Breakdown')),
      body: spending.isEmpty
          ? const Center(child: Text('No expenses yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('Total Spent',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalSpent.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Per-category breakdown
                ...spending.entries.map((entry) {
                  final desc = entry.key;
                  final amount = entry.value;
                  final fraction = totalSpent > 0 ? amount / totalSpent : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(desc,
                                    style: theme.textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text('\$${amount.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(fraction * 100).toStringAsFixed(0)}% of total',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
