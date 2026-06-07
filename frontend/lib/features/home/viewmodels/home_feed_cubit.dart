import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/features/home/viewmodels/home_feed_state.dart';

class HomeFeedCubit extends Cubit<HomeFeedState> {
  HomeFeedCubit() : super(const HomeFeedState());

  void selectTab(String tab) => emit(state.withTab(tab));

  void toggleMood(String label) {
    final newMood = state.selectedMood == label ? null : label;
    emit(state.withMood(newMood));
  }
}
