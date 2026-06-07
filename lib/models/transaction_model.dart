class TransactionModel {
  final int? id;
  final String type;        // 'ingreso' | 'gasto'
  final double amount;
  final String category;
  final String description;
  final String date;        // ISO 8601

  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'type':        type,
    'amount':      amount,
    'category':    category,
    'description': description,
    'date':        date,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id:          m['id'] as int?,
    type:        m['type'] as String,
    amount:      (m['amount'] as num).toDouble(),
    category:    m['category'] as String,
    description: m['description'] as String,
    date:        m['date'] as String,
  );
}
