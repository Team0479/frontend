import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSub,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
} 