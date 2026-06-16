import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

class ThemeModeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeCubit(this._prefs) : super(_resolve(_prefs));

  static ThemeMode _resolve(SharedPreferences prefs) {
    final saved = prefs.getString(_kThemeModeKey);
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeModeKey, mode.name);
    emit(mode);
  }
}
