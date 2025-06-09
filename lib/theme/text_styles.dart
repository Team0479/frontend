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

  // 8bit Wonder
  static const TextStyle bit8Title = TextStyle(
    fontFamily: '8bitWonder',
    fontSize: 24,
    color: AppColors.black,
  );

  static const TextStyle bit8Body = TextStyle(
    fontFamily: '8bitWonder',
    fontSize: 16,
    color: AppColors.black,
  );

  // DungGeunMo
  static const TextStyle dungGeunMoTitle = TextStyle(
    fontFamily: 'DungGeunMo',
    fontSize: 24,
    color: AppColors.black,
  );

  static const TextStyle dungGeunMoBody = TextStyle(
    fontFamily: 'DungGeunMo',
    fontSize: 16,
    color: AppColors.black,
  );

  // Galmuri
  static const TextStyle galmuriTitle = TextStyle(
    fontFamily: 'Galmuri14',
    fontSize: 24,
    color: AppColors.black,
  );

  static const TextStyle galmuriBody = TextStyle(
    fontFamily: 'Galmuri14',
    fontSize: 16,
    color: AppColors.black,
  );

  // Spoqa Han Sans Neo
  static const TextStyle spoqaTitle = TextStyle(
    fontFamily: 'Spoqa Han Sans Neo',
    fontSize: 24,
    color: AppColors.black,
  );

  static const TextStyle spoqaBody = TextStyle(
    fontFamily: 'Spoqa Han Sans Neo',
    fontSize: 16,
    color: AppColors.black,
  );
} 