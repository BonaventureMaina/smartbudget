import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service = TransactionService();
  List<Transaction> _transactions = [];
  double? _forecast;
  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  double? get forecast => _forecast;
  bool get loading => _loading;

  Future<void> fetchTransactions() async {
    _loading = true;
    notifyListeners();
    try {
      _transactions = await _service.fetchTransactions();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    required double amount,
    required String type,
    String? description,
    int? categoryId,
  }) async {
    await _service.createTransaction(
      amount: amount,
      type: type,
      description: description,
      categoryId: categoryId,
    );
    await fetchTransactions();  // refresh list
  }

  Future<void> fetchForecast() async {
    try {
      final data = await _service.fetchForecast();
      _forecast = data['next_month_spending_forecast']?.toDouble();
      notifyListeners();
    } catch (_) {}
  }
}
