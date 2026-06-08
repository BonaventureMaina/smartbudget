import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null && !_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
  }

  Future<void> _loadData() async {
    final txProvider = context.read<TransactionProvider>();
    await Future.wait([
      txProvider.fetchTransactions(),
      txProvider.fetchForecast(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final expenses = txProvider.transactions
        .where((t) => t.type == 'expense')
        .toList();
    final Map<String, double> categoryTotals = {};
    for (final txn in expenses) {
      final label = txn.description ?? 'Other';
      categoryTotals[label] = (categoryTotals[label] ?? 0) + txn.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBudget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Budgets',
            onPressed: () => Navigator.of(context).pushNamed('/budgets'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: txProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next Month Forecast',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              txProvider.forecast != null
                                  ? '\$${txProvider.forecast!.toStringAsFixed(2)}'
                                  : 'Not enough data',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (categoryTotals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('Expenses Breakdown',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: categoryTotals.entries.map((e) {
                                      return PieChartSectionData(
                                        value: e.value,
                                        title: e.key,
                                        radius: 60,
                                        titleStyle: const TextStyle(fontSize: 10),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Transactions',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  if (txProvider.transactions.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final txn = txProvider.transactions[index];
                          return ListTile(
                            leading: Icon(
                              txn.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: txn.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(txn.description ?? 'No description'),
                            subtitle: Text(
                              '\$${txn.amount.toStringAsFixed(2)} · ${txn.type}',
                            ),
                            trailing: Text(
                              '${txn.date.month}/${txn.date.day}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                        childCount: txProvider.transactions.length,
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-transaction');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
