import 'package:equatable/equatable.dart';

class DiscoverState extends Equatable {
  final int selectedFilterIndex;
  final List<int> selectedGenreIndices;
  final List<String> recentSearches;

  const DiscoverState({
    this.selectedFilterIndex = 0,
    this.selectedGenreIndices = const [],
    this.recentSearches = const ['Death Note', 'Sci-Fi', 'Dark Series'],
  });

  DiscoverState copyWith({
    int? selectedFilterIndex,
    List<int>? selectedGenreIndices,
    List<String>? recentSearches,
  }) {
    return DiscoverState(
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      selectedGenreIndices: selectedGenreIndices ?? this.selectedGenreIndices,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  List<Object> get props => [
        selectedFilterIndex,
        selectedGenreIndices,
        recentSearches,
      ];
}
