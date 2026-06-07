import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/local_model.dart';
import '../../utils/constants.dart';

class AddEditLocalScreen extends StatefulWidget {
  final LocalModel? local;
  const AddEditLocalScreen({super.key, this.local});
  @override
  State<AddEditLocalScreen> createState() => _AddEditLocalScreenState();
}

class _AddEditLocalScreenState extends State<AddEditLocalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _scheduleCtrl;
  String _category = kCategories[1]; // Restaurantes

  bool get _isEditing => widget.local != null;

  @override
  void initState() {
    super.initState();
    final l = widget.local;
    _nameCtrl     = TextEditingController(text: l?.name ?? '');
    _addressCtrl  = TextEditingController(text: l?.address ?? '');
    _phoneCtrl    = TextEditingController(text: l?.phone ?? '');
    _descCtrl     = TextEditingController(text: l?.description ?? '');
    _scheduleCtrl = TextEditingController(text: l?.schedule ?? '');
    _category     = l?.category ?? kCategories[1];
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _phoneCtrl.dispose();
    _descCtrl.dispose(); _scheduleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final local = LocalModel(
      id: widget.local?.id,
      name: _nameCtrl.text.trim(),
      category: _category,
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      schedule: _scheduleCtrl.text.trim(),
    );
    if (_isEditing) await _db.updateLocal(local);
    else await _db.insertLocal(local);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar local' : 'Nuevo local'),
        backgroundColor: kPrimary, foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_nameCtrl, 'Nombre del local', Icons.store, required: true),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _deco('Categoría', Icons.category),
              items: kCategories.skip(1).map((c) => DropdownMenuItem(
                value: c,
                child: Row(children: [
                  Icon(kCategoryIcons[c], size: 18, color: kCategoryColors[c]),
                  const SizedBox(width: 8), Text(c),
                ]),
              )).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),
            _field(_addressCtrl, 'Dirección', Icons.location_on, required: true),
            const SizedBox(height: 14),
            _field(_phoneCtrl, 'Teléfono', Icons.phone, required: true,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _field(_scheduleCtrl, 'Horario (ej: Lun-Dom 8:00-20:00)', Icons.access_time),
            const SizedBox(height: 14),
            _field(_descCtrl, 'Descripción', Icons.notes, maxLines: 3),
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
      {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
