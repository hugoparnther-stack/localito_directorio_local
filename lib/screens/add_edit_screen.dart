import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class AddEditScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final String initialType;

  const AddEditScreen({
    super.key,
    this.transaction,
    this.initialType = 'gasto',
  });

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db      = DatabaseHelper();

  late String   _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late String   _category;
  late DateTime _date;
  bool _saving = false;

  List<String>            _customNames   = [];
  Map<String, IconData>   _customIcons   = {};

  bool get _isEditing => widget.transaction != null;

  /// Formatea un double con separador de miles para el campo de entrada.
  static String _fmtAmount(double amount) {
    final parts   = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }

  /// Parsea el texto del campo eliminando las comas de miles.
  static double _parseAmount(String text) =>
      double.parse(text.replaceAll(',', ''));

  List<String> get _baseCategories =>
      _type == 'ingreso' ? kIncomeCategories : kExpenseCategories;

  List<String> get _allCategories => [..._baseCategories, ..._customNames];

  IconData _iconFor(String cat) =>
      kCategoryIcons[cat] ?? _customIcons[cat] ?? Icons.label_rounded;

  Color _colorFor(String cat) =>
      kCategoryColors[cat] ?? kPrimary;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type       = t?.type ?? widget.initialType;
    _amountCtrl = TextEditingController(
        text: t != null ? _fmtAmount(t.amount) : '');
    _descCtrl   = TextEditingController(text: t?.description ?? '');
    _date       = t != null ? DateTime.parse(t.date) : DateTime.now();
    _category   = t?.category ?? _baseCategories.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final rows = await _db.getCustomCategories(_type);
    if (!mounted) return;
    final icons = <String, IconData>{};
    for (final r in rows) {
      icons[r['name']!] =
          kSelectableIcons[r['iconKey']] ?? Icons.label_rounded;
    }
    setState(() {
      _customNames = rows.map((r) => r['name']!).toList();
      _customIcons = icons;
    });
  }

  void _onTypeChange(String type) {
    setState(() {
      _type        = type;
      _customNames = [];
      _customIcons = {};
      _category    = _baseCategories.first;
    });
    _loadCategories();
  }

  // ── Selector de categoría (bottom sheet) ─────────────────────────────────
  void _openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Selecciona categoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _allCategories.length + 1,
              itemBuilder: (_, i) {
                if (i == _allCategories.length) {
                  return _tile(
                    icon: Icons.add_rounded,
                    label: 'Nueva',
                    color: kPrimary,
                    selected: false,
                    dotted: true,
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      // Espera a que el bottom sheet se cierre antes de abrir el diálogo
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _addCategoryDialog();
                      });
                    },
                  );
                }
                final cat   = _allCategories[i];
                final color = _colorFor(cat);
                return _tile(
                  icon:     _iconFor(cat),
                  label:    cat,
                  color:    color,
                  selected: cat == _category,
                  onTap: () {
                    setState(() => _category = cat);
                    Navigator.of(sheetCtx).pop();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    bool dotted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: dotted
                  ? Border.all(color: color.withOpacity(0.5), width: 1.5)
                  : selected
                      ? Border.all(color: color, width: 2)
                      : null,
            ),
            child: Icon(icon,
                color: selected ? Colors.white : color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? color : kTextDark,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Diálogo nueva categoría con selector de ícono ────────────────────────
  Future<void> _addCategoryDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _NewCategoryDialog(),
    );

    if (result == null) return;
    final newName = result['name']!;
    final iconKey = result['iconKey']!;

    if (newName.isEmpty) return;
    if (_allCategories.contains(newName)) {
      if (mounted) setState(() => _category = newName);
      return;
    }
    if (mounted) {
      setState(() {
        _customNames = [..._customNames, newName];
        _customIcons = {
          ..._customIcons,
          newName: kSelectableIcons[iconKey] ?? Icons.label_rounded,
        };
        _category = newName;
      });
    }
    _db.addCustomCategory(newName, _type, iconKey: iconKey);
  }

  // ── Fecha ─────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  // ── Guardar ───────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final t = TransactionModel(
      id:          widget.transaction?.id,
      type:        _type,
      amount:      _parseAmount(_amountCtrl.text),
      category:    _category,
      description: _descCtrl.text.trim(),
      date:        _date.toIso8601String(),
    );
    if (_isEditing) await _db.update(t); else await _db.insert(t);
    if (mounted) Navigator.pop(context, true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'ingreso';
    final color    = isIncome ? kIncome : kExpense;
    final catColor = _colorFor(_category);
    final catIcon  = _iconFor(_category);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Editar transacción' : 'Nueva transacción'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(children: [
                    Expanded(child: _typeBtn('ingreso', 'Ingreso',
                        Icons.arrow_downward_rounded, kIncome)),
                    Expanded(child: _typeBtn('gasto', 'Gasto',
                        Icons.arrow_upward_rounded, kExpense)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Monto
              _label('Monto'),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco('Ej: 1,250.00', Icons.attach_money_rounded),
                inputFormatters: [_DecimalFormatter()],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el monto';
                  final n = double.tryParse(v.replaceAll(',', ''));
                  if (n == null || n <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoría
              _label('Categoría'),
              InkWell(
                onTap: _openCategoryPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(catIcon, color: catColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_category,
                        style: const TextStyle(fontSize: 15))),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: kTextGrey),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              _label('Descripción'),
              TextFormField(
                controller: _descCtrl,
                decoration:
                    _deco('¿En qué lo usaste?', Icons.notes_rounded),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Agrega una descripción'
                        : null,
              ),
              const SizedBox(height: 16),

              // Fecha
              _label('Fecha'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _deco('', Icons.calendar_today_rounded),
                  child: Text(formatDate(_date.toIso8601String()),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 28),

              // Guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(_isEditing
                          ? Icons.save_rounded
                          : Icons.check_circle_rounded),
                  label: Text(
                    _isEditing ? 'Actualizar' : 'Guardar',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBtn(String type, String label, IconData icon, Color color) {
    final sel = _type == type;
    return GestureDetector(
      onTap: () => _onTypeChange(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: sel ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: sel ? Colors.white : Colors.grey,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(
        fontWeight: FontWeight.w600, fontSize: 13, color: kTextDark)),
  );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: kTextGrey),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kExpense)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kExpense)),
  );
}

// ── Formateador de moneda ────────────────────────────────────────────────────
/// Muestra separadores de miles y hasta 2 decimales. Ej: 1,250.50
class _DecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Quitar comas de miles; normalizar coma decimal → punto
    final clean = newValue.text
        .replaceAll(',', '')   // quita separadores previos
        .replaceAll(' ', '');  // quita espacios

    // Solo dígitos y un punto
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(clean)) return oldValue;

    // Máximo 2 decimales
    final dotIdx = clean.indexOf('.');
    if (dotIdx != -1 && clean.length - dotIdx - 1 > 2) return oldValue;

    // Separar parte entera y decimal
    String intPart;
    String suffix = '';
    if (dotIdx != -1) {
      intPart = clean.substring(0, dotIdx);
      suffix  = '.${clean.substring(dotIdx + 1)}';
    } else {
      intPart = clean;
    }

    // Agregar separador de miles a la parte entera
    if (intPart.isNotEmpty) {
      intPart = intPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }

    final result = '$intPart$suffix';
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ── Widget independiente para el diálogo (evita el bug de StatefulBuilder) ──
class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _ctrl = TextEditingController();
  String _selectedKey = 'label';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Nombre (Ej: Mascota, Gym...)',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ícono:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: kSelectableIcons.length,
            itemBuilder: (_, i) {
              final entry = kSelectableIcons.entries.elementAt(i);
              final isSelected = entry.key == _selectedKey;
              return GestureDetector(
                onTap: () => setState(() => _selectedKey = entry.key),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kPrimary
                        : kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.value,
                      color: isSelected ? Colors.white : kPrimary,
                      size: 20),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final name = _ctrl.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop({
              'name':    name,
              'iconKey': _selectedKey,
            });
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
