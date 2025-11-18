class Transaction {
  final int? id;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.byName(map['type']),
    );
  }
}

enum TransactionType {
  income,
  expense,
  savings,
}
