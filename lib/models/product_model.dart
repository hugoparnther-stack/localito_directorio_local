class ProductModel {
  final int? id;
  final int localId;
  final String name;
  final String description;
  final double price;
  final String category;   // sub-categoría dentro del local
  final int isAvailable;

  ProductModel({
    this.id,
    required this.localId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isAvailable = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'local_id': localId,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'is_available': isAvailable,
  };

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
    id: m['id'] as int?,
    localId: m['local_id'] as int,
    name: m['name'] as String,
    description: m['description'] as String,
    price: (m['price'] as num).toDouble(),
    category: m['category'] as String,
    isAvailable: m['is_available'] as int? ?? 1,
  );
}
