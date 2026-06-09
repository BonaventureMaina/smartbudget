import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;
  final TransactionService _txService = TransactionService();
  final AuthService _authService = AuthService();

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

  Future<void> _deleteTransaction(int id) async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        await _txService.deleteTransaction(id, token);
        await _loadData();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    final showLoading = txProvider.loading && txProvider.transactions.isEmpty;

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
            icon: const Icon(Icons.pie_chart_outline),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-transaction'),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: showLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Forecast card
                  SliverToBoxAdapter(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_up, color: theme.colorScheme.primary, size: 28),
                                const SizedBox(width: 12),
                                Text('Next Month Forecast',
                                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              txProvider.forecast != null
                                  ? '\$${txProvider.forecast!.toStringAsFixed(2)}'
                                  : 'Not enough data',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: txProvider.forecast != null
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Pie chart card
                  if (categoryTotals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expenses Breakdown',
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 220,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 40,
                                    sections: categoryTotals.entries.map((e) {
                                      final color = _getColor(categoryTotals.keys.toList().indexOf(e.key));
                                      return PieChartSectionData(
                                        value: e.value,
                                        color: color,
                                        title: e.key.length > 10
                                            ? '${e.key.substring(0, 8)}..'
                                            : e.key,
                                        titleStyle: const TextStyle(fontSize: 11, color: Colors.white70),
                                        radius: 70,
                                      );
                                    }).toList(),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Transactions header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('Recent Transactions',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    ),
                  ),
                  // Transaction list
                  if (txProvider.transactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text('No transactions yet',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final txn = txProvider.transactions[index];
                          final isExpense = txn.type == 'expense';
                          return Dismissible(
                            key: Key(txn.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.redAccent,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteTransaction(txn.id),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isExpense ? Colors.redAccent.withOpacity(0.15) : Colors.greenAccent.withOpacity(0.15),
                                  child: Icon(
                                    isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: isExpense ? Colors.redAccent : Colors.greenAccent,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  txn.description ?? 'No description',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '\$${txn.amount.toStringAsFixed(2)} · ${txn.type}',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                                trailing: Text(
                                  '${txn.date.month}/${txn.date.day}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: txProvider.transactions.length,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Color _getColor(int index) {
    const palette = [
      Color(0xFF6C63FF),
      Color(0xFFE91E63),
      Color(0xFF00BFA5),
      Color(0xFFFFA726),
      Color(0xFF9C27B0),
      Color(0xFF29B6F6),
      Color(0xFFEF5350),
      Color(0xFF66BB6A),
    ];
    return palette[index % palette.length];
  }
}
