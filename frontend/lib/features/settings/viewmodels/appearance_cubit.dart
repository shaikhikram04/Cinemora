import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'appearance_state.dart';

class AppearanceCubit extends Cubit<AppearanceState> {
  final ThemeModeCubit _themeModeCubit;

  AppearanceCubit(this._themeModeCubit)
      : super(AppearanceState(
          selectedTheme: _indexFrom(_themeModeCubit.state),
        ));

  static int _indexFrom(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 0,
        ThemeMode.light => 1,
        ThemeMode.system => 2,
      };

  static ThemeMode _modeFrom(int index) => switch (index) {
        0 => ThemeMode.dark,
        1 => ThemeMode.light,
        _ => ThemeMode.system,
      };

  Future<void> selectTheme(int index) async {
    await _themeModeCubit.setMode(_modeFrom(index));
    emit(state.copyWith(selectedTheme: index));
  }
}
