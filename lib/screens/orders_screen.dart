import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../utils/constants.dart';
import '../widgets/order_tracker.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _db = DatabaseHelper();
  List<OrderModel> _orders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final list = await _db.getOrders();
    if (mounted) setState(() => _orders = list);
  }

  Future<void> _showDetail(OrderModel order) async {
    final items = await _db.getOrderItems(order.id!);
    if (!mounted) return;
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(order.localName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: kTextDark)),
                      Text('Pedido #${order.id?.toString().padLeft(4, '0')}',
                          style: const TextStyle(color: kTextGrey, fontSize: 12)),
                    ])),
                    Text(fmt.format(order.total),
                        style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                  const Divider(height: 30),
                  // Order tracking
                  const Text('Seguimiento del pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
                  const SizedBox(height: 20),
                  OrderTracker(status: order.status),
                  const Divider(height: 30),
                  // Items
                  const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
                  const SizedBox(height: 12),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                          borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('${item.quantity}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500, color: kTextDark))),
                      Text(fmt.format(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary)),
                    ]),
                  )),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
                    Text(fmt.format(order.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kPrimary)),
                  ]),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 2);
    final dateFmt = DateFormat('dd MMM · HH:mm');

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Mis Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade100, height: 1)),
      ),
      body: _orders.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, size: 60, color: kPrimary),
              ),
              const SizedBox(height: 20),
              const Text('Aún no tienes pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
              const SizedBox(height: 8),
              Text('Haz tu primer pedido y rastréalo aquí', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _orders.length,
              itemBuilder: (_, i) {
                final o = _orders[i];
                final date = DateTime.tryParse(o.date) ?? DateTime.now();
                final stepIndex = kOrderStatusIndex[o.status.toLowerCase()] ?? 0;
                final statusColor = stepIndex == 3 ? kSuccess : kPrimary;

                return GestureDetector(
                  onTap: () => _showDetail(o),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                            borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(o.localName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTextDark)),
                          Text(dateFmt.format(date), style: const TextStyle(color: kTextGrey, fontSize: 12)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(fmt.format(o.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)),
                            child: Text(o.status,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ]),
                      const SizedBox(height: 14),
                      // Mini progress bar
                      Row(children: List.generate(kOrderSteps.length, (idx) {
                        final done = idx <= stepIndex;
                        return Expanded(child: Row(children: [
                          Expanded(child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: done ? const LinearGradient(colors: [kPrimary, kPrimaryDark]) : null,
                              color: done ? null : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2)),
                          )),
                          if (idx < kOrderSteps.length - 1) const SizedBox(width: 2),
                        ]));
                      })),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: kOrderSteps.map((s) => Text(s,
                              style: TextStyle(fontSize: 9, color: kTextGrey,
                                  fontWeight: kOrderSteps.indexOf(s) <= stepIndex ? FontWeight.bold : FontWeight.normal))).toList()),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        const Icon(Icons.touch_app_rounded, size: 13, color: kTextGrey),
                        const SizedBox(width: 4),
                        Text('Toca para ver detalles', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
