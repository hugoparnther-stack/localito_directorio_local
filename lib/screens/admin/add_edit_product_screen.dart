import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';

class AddEditProductScreen extends StatefulWidget {
  final int localId;
  final ProductModel? product;
  const AddEditProductScreen({super.key, required this.localId, this.product});
  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _catCtrl;
  bool _available = true;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl  = TextEditingController(text: p?.name ?? '');
    _descCtrl  = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _catCtrl   = TextEditingController(text: p?.category ?? '');
    _available = p?.isAvailable == 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final product = ProductModel(
      id: widget.product?.id,
      localId: widget.localId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.replaceAll(',', '.')),
      category: _catCtrl.text.trim().isEmpty ? 'General' : _catCtrl.text.trim(),
      isAvailable: _available ? 1 : 0,
    );
    if (_isEditing) await _db.updateProduct(product);
    else await _db.insertProduct(product);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
        backgroundColor: kPrimary, foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_nameCtrl, 'Nombre del producto', Icons.inventory_2, required: true),
            const SizedBox(height: 14),
            _field(_catCtrl, 'Sub-categoría (ej: Platos, Bebidas)', Icons.category),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceCtrl,
              decoration: _deco('Precio', Icons.attach_money),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa el precio';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Precio inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _field(_descCtrl, 'Descripción', Icons.notes, maxLines: 3),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _available,
              onChanged: (v) => setState(() => _available = v),
              title: const Text('Disponible'),
              subtitle: const Text('Desactiva si el producto no está en stock'),
              activeColor: kPrimary,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      decoration: _deco(label, icon),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null : null,
    );
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    filled: true, fillColor: Colors.grey.shade50,
  );
}
