import 'package:flutter_bloc/flutter_bloc.dart';
import 'privacy_security_state.dart';

class PrivacySecurityCubit extends Cubit<PrivacySecurityState> {
  PrivacySecurityCubit() : super(const PrivacySecurityState());

  void setPublicProfile(bool value) => emit(state.copyWith(publicProfile: value));
  void setShowRatings(bool value) => emit(state.copyWith(showRatings: value));
  void setShowRankings(bool value) => emit(state.copyWith(showRankings: value));
  void setShowWatchHistory(bool value) => emit(state.copyWith(showWatchHistory: value));
}
