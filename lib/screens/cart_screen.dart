import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final db = DatabaseHelper();
    await db.saveOrder(
      OrderModel(localId: cart.localId!, localName: cart.localName,
          total: cart.total, date: DateTime.now().toIso8601String(), status: 'pendiente'),
      cart.toOrderItems(),
    );
    cart.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()), (r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Pedido confirmado! 🎉'), backgroundColor: kSuccess, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 2);
    final items = cart.items.values.toList();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Mi Carrito', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => cart.clear(),
              child: const Text('Vaciar', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.shopping_bag_outlined, size: 64, color: kPrimary),
              ),
              const SizedBox(height: 20),
              const Text('Tu carrito está vacío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
              const SizedBox(height: 8),
              Text('Agrega productos desde un local', style: TextStyle(color: Colors.grey.shade400)),
            ]))
          : Column(children: [
              // Local banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                  borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Pedido de: ${cart.localName}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              // Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                      child: Row(children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [kPrimary, Color(0xFFFF8A65)]),
                            borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.fastfood_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextDark)),
                          Text(fmt.format(item.product.price), style: const TextStyle(color: kTextGrey, fontSize: 12)),
                        ])),
                        Row(children: [
                          GestureDetector(
                            onTap: () => cart.decreaseItem(item.product.id!),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.remove_rounded, size: 16, color: kPrimary),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          GestureDetector(
                            onTap: () => cart.addItem(item.product, cart.localId!, cart.localName),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                                borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
              ),
              // Summary + button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Subtotal (${cart.itemCount} items)', style: const TextStyle(color: kTextGrey)),
                    Text(fmt.format(cart.total), style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Envío', style: TextStyle(color: kTextGrey)),
                    const Text('Gratis', style: TextStyle(color: kSuccess, fontWeight: FontWeight.bold)),
                  ]),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
                    Text(fmt.format(cart.total),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: kPrimary)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Confirmar pedido', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: Text('Total: ${fmt.format(cart.total)}\nLocal: ${cart.localName}'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () { Navigator.pop(context); _confirmOrder(context); },
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.check_circle_outline_rounded),
                        SizedBox(width: 8),
                        Text('Realizar pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }
}
