import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OrderTracker extends StatelessWidget {
  final String status;
  const OrderTracker({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final currentStep = kOrderStatusIndex[status.toLowerCase()] ?? 0;
    return Column(
      children: List.generate(kOrderSteps.length, (i) {
        final isDone = i <= currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == kOrderSteps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDone
                      ? const LinearGradient(colors: [kPrimary, kPrimaryDark])
                      : null,
                  color: isDone ? null : Colors.grey.shade200,
                  boxShadow: isCurrent ? [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] : null,
                ),
                child: Center(
                  child: isDone
                      ? (isCurrent && currentStep < kOrderSteps.length - 1
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_rounded, color: Colors.white, size: 16))
                      : Text('${i + 1}', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 2, height: 40,
                  decoration: BoxDecoration(
                    gradient: isDone && i < currentStep
                        ? const LinearGradient(colors: [kPrimary, kPrimaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                        : null,
                    color: isDone && i < currentStep ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(kOrderSteps[i],
                      style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          fontSize: isCurrent ? 15 : 13,
                          color: isDone ? kTextDark : kTextGrey)),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(_stepDescription(i),
                          style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _stepDescription(int step) {
    switch (step) {
      case 0: return 'Tu pedido ha sido recibido ✓';
      case 1: return 'El local está preparando tu pedido...';
      case 2: return 'Tu pedido está en camino 🛵';
      case 3: return '¡Pedido entregado! 🎉';
      default: return '';
    }
  }
}
