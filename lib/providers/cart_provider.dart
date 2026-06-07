import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/order_item_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  int? _localId;
  String _localName = '';
  final Map<int, CartItem> _items = {};

  int? get localId => _localId;
  String get localName => _localName;
  Map<int, CartItem> get items => Map.unmodifiable(_items);
  int get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);
  double get total => _items.values.fold(0.0, (s, i) => s + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  /// Retorna true si se agregó con éxito.
  /// Retorna false si el local es diferente (requiere confirmación del usuario).
  bool addItem(ProductModel product, int localId, String localName) {
    if (_localId != null && _localId != localId && _items.isNotEmpty) {
      return false; // carrito de otro local
    }
    _localId = localId;
    _localName = localName;
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id!] = CartItem(product: product);
    }
    notifyListeners();
    return true;
  }

  void removeItem(int productId) {
    _items.remove(productId);
    if (_items.isEmpty) clear();
    notifyListeners();
  }

  void decreaseItem(int productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      removeItem(productId);
      return;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _localId = null;
    _localName = '';
    notifyListeners();
  }

  List<OrderItemModel> toOrderItems() => _items.values.map((ci) => OrderItemModel(
    orderId: 0,
    productId: ci.product.id!,
    productName: ci.product.name,
    price: ci.product.price,
    quantity: ci.quantity,
  )).toList();
}
