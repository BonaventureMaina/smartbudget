import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final txProvider = context.read<TransactionProvider>();
    if (txProvider.budgets.isEmpty) txProvider.fetchBudgets();
    if (txProvider.transactions.isEmpty) txProvider.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    final Map<int, double> spendingByCategory = {};
    for (final txn in txProvider.transactions) {
      if (txn.type == 'expense' && txn.categoryId != null) {
        spendingByCategory[txn.categoryId!] =
            (spendingByCategory[txn.categoryId!] ?? 0) + txn.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Limits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Set budget',
            onPressed: () async {
              await Navigator.of(context).pushNamed('/set-budget');
              txProvider.fetchBudgets();
            },
          ),
        ],
      ),
      body: txProvider.budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.savings_outlined, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('No budgets set', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/set-budget').then((_) => txProvider.fetchBudgets());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: txProvider.budgets.map((b) {
                final categoryId = b['category_id'] as int;
                final categoryName = b['category_name'] as String? ?? 'Unknown';
                final limit = (b['amount'] as num).toDouble();
                final spent = spendingByCategory[categoryId] ?? 0.0;
                final fraction = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                final isOver = spent > limit;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(categoryName, style: theme.textTheme.titleMedium),
                            Text(
                              'KES ${spent.toStringAsFixed(0)} / KES ${limit.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade800,
                            color: isOver ? Colors.redAccent : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOver
                              ? 'Over budget by KES ${(spent - limit).toStringAsFixed(0)}'
                              : '${(fraction * 100).toStringAsFixed(0)}% used',
                          style: TextStyle(color: isOver ? Colors.redAccent : Colors.grey, fontSize: 12),
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
