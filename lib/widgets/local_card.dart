import 'package:flutter/material.dart';
import '../models/local_model.dart';
import '../utils/constants.dart';

class LocalCard extends StatelessWidget {
  final LocalModel local;
  final VoidCallback onTap;
  const LocalCard({super.key, required this.local, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradients = kCategoryGradients[local.category] ?? [Colors.grey, Colors.grey.shade700];
    final icon = kCategoryIcons[local.category] ?? Icons.store;
    final color = kCategoryColors[local.category] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image banner
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(colors: gradients, begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.3))),
                  // Category badge
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Text(local.category,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 2),
                          Text('4.${(local.id ?? 5) % 5 + 3}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_rounded, size: 13, color: color),
                    const SizedBox(width: 3),
                    Expanded(child: Text(local.address,
                        style: const TextStyle(color: kTextGrey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _InfoChip(icon: Icons.delivery_dining_rounded, label: 'Delivery', color: color),
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.access_time_rounded, label: '20-35 min', color: color),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradients),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Ver menú', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}
