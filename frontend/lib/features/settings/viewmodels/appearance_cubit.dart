import 'package:flutter_bloc/flutter_bloc.dart';
import 'appearance_state.dart';

class AppearanceCubit extends Cubit<AppearanceState> {
  AppearanceCubit() : super(const AppearanceState());

  void selectTheme(int index) => emit(state.copyWith(selectedTheme: index));
}
