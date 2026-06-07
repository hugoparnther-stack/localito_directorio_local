import 'package:flutter/material.dart';

const Color kPrimary     = Color(0xFF6C63FF);
const Color kIncome      = Color(0xFF27AE60);
const Color kExpense     = Color(0xFFE74C3C);
const Color kBackground  = Color(0xFFF0F2F5);
const Color kTextDark    = Color(0xFF2C3E50);
const Color kTextGrey    = Color(0xFF95A5A6);

const List<String> kExpenseCategories = [
  'Alimentación', 'Transporte', 'Salud', 'Educación',
  'Servicios', 'Entretenimiento', 'Compras', 'Otros',
];

const List<String> kIncomeCategories = [
  'Salario', 'Freelance', 'Inversiones', 'Regalo', 'Otros',
];

const Map<String, IconData> kCategoryIcons = {
  'Alimentación':    Icons.restaurant_rounded,
  'Transporte':      Icons.directions_car_rounded,
  'Salud':           Icons.local_hospital_rounded,
  'Educación':       Icons.school_rounded,
  'Servicios':       Icons.receipt_long_rounded,
  'Entretenimiento': Icons.movie_rounded,
  'Compras':         Icons.shopping_bag_rounded,
  'Otros':           Icons.more_horiz_rounded,
  'Salario':         Icons.work_rounded,
  'Freelance':       Icons.laptop_rounded,
  'Inversiones':     Icons.trending_up_rounded,
  'Regalo':          Icons.card_giftcard_rounded,
};

/// Íconos disponibles para categorías personalizadas
const Map<String, IconData> kSelectableIcons = {
  'label':         Icons.label_rounded,
  'pets':          Icons.pets_rounded,
  'fitness':       Icons.fitness_center_rounded,
  'sports':        Icons.sports_soccer_rounded,
  'music':         Icons.music_note_rounded,
  'flight':        Icons.flight_rounded,
  'home':          Icons.home_rounded,
  'phone':         Icons.smartphone_rounded,
  'coffee':        Icons.coffee_rounded,
  'book':          Icons.menu_book_rounded,
  'games':         Icons.games_rounded,
  'camera':        Icons.photo_camera_rounded,
  'bank':          Icons.account_balance_rounded,
  'child':         Icons.child_care_rounded,
  'bike':          Icons.directions_bike_rounded,
  'dining':        Icons.local_dining_rounded,
  'beach':         Icons.beach_access_rounded,
  'spa':           Icons.spa_rounded,
  'car_repair':    Icons.car_repair_rounded,
  'bolt':          Icons.bolt_rounded,
  'water':         Icons.water_drop_rounded,
  'wifi':          Icons.wifi_rounded,
  'celebration':   Icons.celebration_rounded,
  'volunteer':     Icons.volunteer_activism_rounded,
};

const Map<String, Color> kCategoryColors = {
  'Alimentación':    Color(0xFFFF7043),
  'Transporte':      Color(0xFF42A5F5),
  'Salud':           Color(0xFF66BB6A),
  'Educación':       Color(0xFFAB47BC),
  'Servicios':       Color(0xFFFFB300),
  'Entretenimiento': Color(0xFFEC407A),
  'Compras':         Color(0xFF26C6DA),
  'Otros':           Color(0xFF78909C),
  'Salario':         Color(0xFF43A047),
  'Freelance':       Color(0xFF1E88E5),
  'Inversiones':     Color(0xFF00897B),
  'Regalo':          Color(0xFFE91E63),
};
