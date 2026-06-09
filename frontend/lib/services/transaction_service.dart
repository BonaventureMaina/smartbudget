import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'auth_service.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<List<Transaction>> fetchTransactions() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<Transaction> createTransaction({
    required double amount,
    required String type,
    String? description,
    int? categoryId,
  }) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'type': type,
        'description': description,
        'category_id': categoryId,
      }),
    );
    if (response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transaction');
    }
  }

  Future<Map<String, dynamic>> fetchForecast() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/forecast'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch forecast');
    }
  }

  Future<void> deleteTransaction(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
