import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(const EditProfileState());

  void toggleGenre(String genre) {
    final current = List<String>.of(state.selectedGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    emit(state.copyWith(selectedGenres: current));
  }

  void selectLanguage(String language) => emit(state.copyWith(selectedLanguage: language));
  void selectEra(String era) => emit(state.copyWith(selectedEra: era));
  void togglePreview() => emit(state.copyWith(showPreview: !state.showPreview));
}
