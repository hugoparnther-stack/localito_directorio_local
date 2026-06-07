import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../models/local_model.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import 'add_edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  final LocalModel local;
  const ManageProductsScreen({super.key, required this.local});
  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _db = DatabaseHelper();
  List<ProductModel> _products = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final list = await _db.getProductsByLocal(widget.local.id!);
    if (mounted) setState(() => _products = list);
  }

  Future<void> _delete(ProductModel p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) { await _db.deleteProduct(p.id!); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 2);
    final color = kCategoryColors[widget.local.category] ?? kPrimary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos — ${widget.local.name}', overflow: TextOverflow.ellipsis),
        backgroundColor: color, foregroundColor: Colors.white,
      ),
      body: _products.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Aún no hay productos', style: TextStyle(color: Colors.grey.shade500)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _products.length,
              itemBuilder: (_, i) {
                final p = _products[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.category} · ${p.description}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(fmt.format(p.price),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AddEditProductScreen(
                                  localId: widget.local.id!, product: p)));
                          _load();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _delete(p),
                      ),
                    ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddEditProductScreen(localId: widget.local.id!)));
          _load();
        },
        backgroundColor: color, foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }
}
