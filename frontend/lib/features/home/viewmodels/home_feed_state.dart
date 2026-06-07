import 'package:equatable/equatable.dart';

class HomeFeedState extends Equatable {
  final String selectedTab;
  final String? selectedMood;

  const HomeFeedState({
    this.selectedTab = '✨   For You',
    this.selectedMood,
  });

  HomeFeedState withTab(String tab) =>
      HomeFeedState(selectedTab: tab, selectedMood: selectedMood);

  HomeFeedState withMood(String? mood) =>
      HomeFeedState(selectedTab: selectedTab, selectedMood: mood);

  @override
  List<Object?> get props => [selectedTab, selectedMood];
}
