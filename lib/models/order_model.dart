class OrderModel {
  final int? id;
  final int localId;
  final String localName;
  final double total;
  final String date;
  final String status; // pendiente | confirmado | entregado

  OrderModel({
    this.id,
    required this.localId,
    required this.localName,
    required this.total,
    required this.date,
    this.status = 'pendiente',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'local_id': localId,
    'local_name': localName,
    'total': total,
    'date': date,
    'status': status,
  };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    id: m['id'] as int?,
    localId: m['local_id'] as int,
    localName: m['local_name'] as String,
    total: (m['total'] as num).toDouble(),
    date: m['date'] as String,
    status: m['status'] as String? ?? 'pendiente',
  );
}
