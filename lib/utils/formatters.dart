String formatAmount(double amount) {
  final parts   = amount.toStringAsFixed(2).split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$intPart.${parts[1]}';
}

String formatDate(String iso) {
  final dt = DateTime.parse(iso);
  const months = [
    '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
