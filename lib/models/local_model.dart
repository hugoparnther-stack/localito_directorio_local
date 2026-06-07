class LocalModel {
  final int? id;
  final String name;
  final String category;   // Restaurantes | Supermercados | Farmacias
  final String address;
  final String phone;
  final String description;
  final String? schedule;  // Ej: "Lun-Vie 8:00-20:00"
  final int isActive;      // 1 = activo, 0 = inactivo

  LocalModel({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.description,
    this.schedule,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'address': address,
    'phone': phone,
    'description': description,
    'schedule': schedule ?? '',
    'is_active': isActive,
  };

  factory LocalModel.fromMap(Map<String, dynamic> m) => LocalModel(
    id: m['id'] as int?,
    name: m['name'] as String,
    category: m['category'] as String,
    address: m['address'] as String,
    phone: m['phone'] as String,
    description: m['description'] as String,
    schedule: m['schedule'] as String?,
    isActive: m['is_active'] as int? ?? 1,
  );
}
