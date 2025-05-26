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
  static const TextStyle pixelTitle = TextStyle(
    fontFamily: '8bitWonder',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  static const TextStyle pixelBody = TextStyle(
    fontFamily: 'PixeloidSans',
    fontSize: 16,
    color: AppColors.text,
  );
  static const TextStyle pixelButton = TextStyle(
    fontFamily: 'PixeloidSans',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  static const TextStyle pixelKoreanTitle = TextStyle(
    fontFamily: 'DungGeunMo',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  static const TextStyle pixelKoreanBody = TextStyle(
    fontFamily: 'DungGeunMo',
    fontSize: 16,
    color: AppColors.text,
  );
  static const TextStyle pixelKoreanCaption = TextStyle(
    fontFamily: 'Galmuri14',
    fontSize: 13,
    color: AppColors.textSub,
  );
} 