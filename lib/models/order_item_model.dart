class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'product_name': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItemModel.fromMap(Map<String, dynamic> m) => OrderItemModel(
    id: m['id'] as int?,
    orderId: m['order_id'] as int,
    productId: m['product_id'] as int,
    productName: m['product_name'] as String,
    price: (m['price'] as num).toDouble(),
    quantity: m['quantity'] as int,
  );
}
