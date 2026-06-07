import 'package:flutter_bloc/flutter_bloc.dart';
import 'data_library_state.dart';

class DataLibraryCubit extends Cubit<DataLibraryState> {
  DataLibraryCubit() : super(const DataLibraryState());

  void clearCache() => emit(state.copyWith(cacheCleared: true));
}
