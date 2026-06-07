import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/local_model.dart';
import '../../utils/constants.dart';
import 'add_edit_local_screen.dart';
import 'manage_products_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _db = DatabaseHelper();
  List<LocalModel> _locals = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final list = await _db.getLocals();
    if (mounted) setState(() => _locals = list);
  }

  Future<void> _delete(LocalModel local) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar local'),
        content: Text('¿Eliminar "${local.name}" y todos sus productos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) { await _db.deleteLocal(local.id!); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Locales'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: _locals.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.store_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No hay locales registrados',
                    style: TextStyle(color: Colors.grey.shade500)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _locals.length,
              itemBuilder: (_, i) {
                final local = _locals[i];
                final color = kCategoryColors[local.category] ?? Colors.grey;
                final icon = kCategoryIcons[local.category] ?? Icons.store;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(local.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(local.category,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
                        tooltip: 'Productos',
                        onPressed: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ManageProductsScreen(local: local)));
                          _load();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AddEditLocalScreen(local: local)));
                          _load();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Eliminar',
                        onPressed: () => _delete(local),
                      ),
                    ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditLocalScreen()));
          _load();
        },
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo local'),
      ),
    );
  }
}
