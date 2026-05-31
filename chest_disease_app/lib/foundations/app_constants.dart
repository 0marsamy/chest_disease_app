import 'dart:convert';
import 'package:chest_disease_app/core/utils/extenstions/navigation_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/data/local_services/app_caching_helper.dart';
import '../features/login/data/models/login_model.dart';
import '../generated/l10n.dart';

class AppConstants {
  AppConstants._();

  static AppConstants? _instance;

  static AppConstants get instance {
    _instance ??= AppConstants._();
    return _instance!;
  }

  static BuildContext context =
      NavigationExtensions.navigatorKey.currentContext!;

  static bool onBoarding = false;
  static String accessToken = '';
  static User? user;
  static String? location;

  /// API key for Gemiai / Gemini (used by the in-app medical chatbot)
  ///
  /// NOTE: Hard-coding keys in source is not secure for production.
  /// Replace this value with a secure storage approach before releasing.
  static const String gemiaiApiKey = 'AIzaSyDit_UdKFWWdMAMx4DFPwVX-vr_g6-0q74';

  static bool langCode = true;
  static LatLng? currentLocation;
  static ThemeMode themeMode = ThemeMode.system;

  static cacheString({required String key, required dynamic value}) async {
    await AppCacheHelper.setSecuredString(key: key, value: value);
  }

  static setToken(String token) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.tokenKey,
      value: token,
    );
    accessToken = token;
  }

  static setLanguage(bool language) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.language,
      value: language.toString(),
    );
    langCode = language;
  }

  static setThemeMode(ThemeMode mode) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.themeMode,
      value: mode.toString(),
    );
    themeMode = mode;
  }

  static Future<ThemeMode> getThemeMode() async {
    String? cachedTheme = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.themeMode,
    );
    if (cachedTheme == null || cachedTheme.isEmpty) {
      // Default to system theme if not found
      themeMode = ThemeMode.system;
      await setThemeMode(ThemeMode.system);
    } else {
      // Parse the string back to ThemeMode enum
      if (cachedTheme == 'ThemeMode.light') {
        themeMode = ThemeMode.light;
      } else if (cachedTheme == 'ThemeMode.dark') {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.system;
      }
    }
    return themeMode;
  }

  static Future<bool> getLanguage() async {
    // Try to get cached language
    String? cachedLang = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.language,
    );
    if (cachedLang == null || cachedLang.isEmpty) {
      // If not found, get system language
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final isEnglish = systemLocale.languageCode == 'en';
      await setLanguage(isEnglish);
      langCode = isEnglish;
    } else {
      langCode = cachedLang == 'true';
    }
    return langCode;
  }

  static setOnBoardingBoolean(bool value) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.onBoardingKey,
      value: value.toString(),
    );
    onBoarding = value;
  }

  static Future<bool> getOnBoardingBoolean() async {
    String? onBoardingValue = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.onBoardingKey,
    );
    if (onBoardingValue != null && onBoardingValue.isNotEmpty) {
      onBoarding = onBoardingValue == 'true';
    }

    return onBoarding;
  }

  static setUser(User user) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.user,
      value: jsonEncode(user.toJson()), // Serialize to JSON
    );
    AppConstants.user = user;
  }

  static getUser() async {
    String? cacheUser = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.user,
    );
    if (cacheUser != null && cacheUser.isNotEmpty) {
      try {
        AppConstants.user = User.fromJson(jsonDecode(cacheUser));
      } catch (_) {}
    }
  }

  static setBiometricUser(User user) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.biometricUser,
      value: jsonEncode(user.toJson()), // Serialize to JSON
    );
    AppConstants.user = user;
  }

  static getBiometricUser() async {
    String? cacheUser = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.biometricUser,
    );
    if (cacheUser != null && cacheUser.isNotEmpty) {
      return User.fromJson(jsonDecode(cacheUser));
    }
  }

  static Future<String?> getToken() async {
    final token = await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.tokenKey,
    );
    accessToken = token ?? ''; // Update the static accessToken
    return token;
  }

  static getBiometricToken() async {
    return await AppCacheHelper.getSecuredString(
      key: AppCacheHelper.biometricTokenKey,
    );
  }

  static setBiometricToken(String token) async {
    await AppCacheHelper.setSecuredString(
      key: AppCacheHelper.biometricTokenKey,
      value: token,
    );
    accessToken = token;
  }

  static clearLogin() async {
    accessToken = '';
    user = null;
    location = null;
    await AppCacheHelper.clearSecuredData(AppCacheHelper.tokenKey);
    await AppCacheHelper.clearSecuredData(AppCacheHelper.user);
  }

  static List<Map<int, String>> days = [
    {0: S.of(AppConstants.context).sunday},
    {1: S.of(AppConstants.context).monday},
    {2: S.of(AppConstants.context).tuesday},
    {3: S.of(AppConstants.context).wednesday},
    {4: S.of(AppConstants.context).thursday},
    {5: S.of(AppConstants.context).friday},
    {6: S.of(AppConstants.context).saturday},
  ];
}
