import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../foundations/app_constants.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    _loadThemeMode();
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    _themeMode = await AppConstants.getThemeMode();
    emit(ThemeChanged(_themeMode));
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await AppConstants.setThemeMode(mode);
    emit(ThemeChanged(_themeMode));
  }

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.dark) {
      return true;
    } else if (_themeMode == ThemeMode.light) {
      return false;
    } else {
      // System mode
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
