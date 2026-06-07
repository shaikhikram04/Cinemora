import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_session_state.dart';

class CreateSessionCubit extends Cubit<CreateSessionState> {
  CreateSessionCubit() : super(const CreateSessionState());

  void selectContentType(String type) => emit(state.copyWith(contentType: type));

  void toggleGenre(String genre) {
    final current = List<String>.of(state.selectedGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    emit(state.copyWith(selectedGenres: current));
  }
}
