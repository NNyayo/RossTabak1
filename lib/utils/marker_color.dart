import 'package:flutter/material.dart';
import '../core/colors.dart';

Color getMarkerColor(String colorName) {
  return AppColors.markerColors[colorName] ?? Colors.white;
}

Color getMarkerColorForDot(String colorName) {
  switch (colorName) {
    case 'Красный':
      return Colors.red;
    case 'Синий':
      return Colors.blue;
    case 'Зелёный':
      return Colors.green;
    case 'Оранжевый':
      return Colors.orange;
    case 'Фиолетовый':
      return Colors.purple;
    case 'Коричневый':
      return Colors.brown;
    default:
      return Colors.white;
  }
}
