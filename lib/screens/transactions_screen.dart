import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper();
  late TabController _tab;
  List<TransactionModel> _all      = [];
  List<TransactionModel> _incomes  = [];
  List<TransactionModel> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _db.getAll();
    if (mounted) {
      setState(() {
        _all      = all;
        _incomes  = all.where((t) => t.type == 'ingreso').toList();
        _expenses = all.where((t) => t.type == 'gasto').toList();
        _loading  = false;
      });
    }
  }

  void _edit(TransactionModel t) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditScreen(transaction: t)),
    );
    if (ok == true) _load();
  }

  void _confirmDelete(TransactionModel t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "${t.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _db.delete(t.id!);
              _load();
            },
            child: const Text('Eliminar',
                style: TextStyle(color: kExpense)),
          ),
        ],
      ),
    );
  }

  Widget _list(List<TransactionModel> items) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Color(0xFFDDE0E8)),
            SizedBox(height: 12),
            Text('Sin registros', style: TextStyle(color: kTextGrey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (_, i) => TransactionCard(
        transaction: items[i],
        onEdit:   () => _edit(items[i]),
        onDelete: () => _confirmDelete(items[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Mis Transacciones'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _list(_all),
          _list(_incomes),
          _list(_expenses),
        ],
      ),
    );
  }
}
