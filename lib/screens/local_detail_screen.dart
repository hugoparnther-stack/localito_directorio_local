import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/local_model.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import 'cart_screen.dart';

class LocalDetailScreen extends StatefulWidget {
  final LocalModel local;
  const LocalDetailScreen({super.key, required this.local});
  @override
  State<LocalDetailScreen> createState() => _LocalDetailScreenState();
}

class _LocalDetailScreenState extends State<LocalDetailScreen> {
  final _db = DatabaseHelper();
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prods = await _db.getProductsByLocal(widget.local.id!);
    if (mounted) setState(() { _products = prods; _loading = false; });
  }

  Map<String, List<ProductModel>> get _grouped {
    final map = <String, List<ProductModel>>{};
    for (final p in _products) {
      (map[p.category] ??= []).add(p);
    }
    return map;
  }

  void _addToCart(ProductModel product) {
    final cart = context.read<CartProvider>();
    final success = cart.addItem(product, widget.local.id!, widget.local.name);
    if (!success) {
      // Carrito de otro local
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¿Vaciar carrito?'),
          content: Text(
              'Tu carrito tiene productos de "${cart.localName}". '
              '¿Quieres vaciarlo para agregar de ${widget.local.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
              onPressed: () {
                cart.clear();
                cart.addItem(product, widget.local.id!, widget.local.name);
                Navigator.pop(context);
                _showAddedSnack(product);
              },
              child: const Text('Vaciar y agregar'),
            ),
          ],
        ),
      );
    } else {
      _showAddedSnack(product);
    }
  }

  void _showAddedSnack(ProductModel p) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${p.name} agregado al carrito'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Ver carrito',
        textColor: Colors.yellow,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final color = kCategoryColors[widget.local.category] ?? kPrimary;
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.local.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(kCategoryIcons[widget.local.category] ?? Icons.store,
                      size: 60, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
            actions: [
              if (cart.itemCount > 0)
                Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  Positioned(
                    right: 6, top: 6,
                    child: CircleAvatar(
                      radius: 9, backgroundColor: Colors.yellow,
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
            ],
          ),
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.location_on, widget.local.address, color),
                    const SizedBox(height: 8),
                    _infoRow(Icons.phone, widget.local.phone, color),
                    if (widget.local.schedule != null && widget.local.schedule!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.access_time, widget.local.schedule!, color),
                    ],
                    if (widget.local.description.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text(widget.local.description,
                          style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Este local aún no tiene productos',
                      style: TextStyle(color: Colors.grey.shade500)),
                ]),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final categories = _grouped.keys.toList();
                  final entries = _grouped.entries.toList();
                  if (i >= entries.length) return null;
                  final cat = entries[i].key;
                  final prods = entries[i].value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text(cat,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ...prods.map((p) => Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(p.description,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(fmt.format(p.price),
                                      style: TextStyle(
                                          color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 28,
                                    child: ElevatedButton(
                                      onPressed: p.isAvailable == 1 ? () => _addToCart(p) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: color,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      child: const Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  );
                },
                childCount: _grouped.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: cart.itemCount > 0 && cart.localId == widget.local.id
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const CartScreen())),
              backgroundColor: color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text('Ver carrito (${cart.itemCount}) · ${fmt.format(cart.total)}'),
            )
          : null,
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ],
  );
}
