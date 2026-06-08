class Transaction {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String? description;
  final int? categoryId;
  final DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    this.categoryId,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      description: json['description'],
      categoryId: json['category_id'],
      date: DateTime.parse(json['date']),
    );
  }
}
