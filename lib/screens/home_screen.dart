import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  double _income   = 0;
  double _expenses = 0;
  List<TransactionModel> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final income   = await _db.getTotal('ingreso');
    final expenses = await _db.getTotal('gasto');
    final all      = await _db.getAll();
    if (mounted) {
      setState(() {
        _income   = income;
        _expenses = expenses;
        _recent   = all.take(5).toList();
        _loading  = false;
      });
    }
  }

  Future<void> _openAdd(String type) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditScreen(initialType: type)),
    );
    if (ok == true) _load();
  }

  Future<void> _openEdit(TransactionModel t) async {
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
            child:
                const Text('Eliminar', style: TextStyle(color: kExpense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expenses;
    return Scaffold(
      backgroundColor: kBackground,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // ── Header ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5C54E8), Color(0xFF8F87FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft:  Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 20, right: 20, bottom: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Mis Finanzas',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(
                                    Icons.list_alt_rounded,
                                    color: Colors.white),
                                tooltip: 'Ver todas',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const TransactionsScreen()),
                                  );
                                  _load();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text('Saldo disponible',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            formatAmount(balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(
                                child: _miniCard(
                                    'Ingresos', _income,
                                    Icons.arrow_downward_rounded,
                                    kIncome)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _miniCard(
                                    'Gastos', _expenses,
                                    Icons.arrow_upward_rounded,
                                    kExpense)),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // ── Section title ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Últimas transacciones',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDark)),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const TransactionsScreen()),
                              );
                              _load();
                            },
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Recent list ───────────────────────────────────────
                  _recent.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    size: 64,
                                    color: Color(0xFFDDE0E8)),
                                SizedBox(height: 12),
                                Text('No hay transacciones aún',
                                    style: TextStyle(
                                        color: kTextGrey,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => TransactionCard(
                                transaction: _recent[i],
                                onEdit:   () => _openEdit(_recent[i]),
                                onDelete: () =>
                                    _confirmDelete(_recent[i]),
                              ),
                              childCount: _recent.length,
                            ),
                          ),
                        ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 120)),
                ],
              ),
            ),

      // ── FABs ──────────────────────────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_gasto',
            onPressed: () => _openAdd('gasto'),
            backgroundColor: kExpense,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            label: const Text('Gasto'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'fab_ingreso',
            onPressed: () => _openAdd('ingreso'),
            backgroundColor: kIncome,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Ingreso'),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(
      String label, double amount, IconData icon, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
                Text(
                  formatAmount(amount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
