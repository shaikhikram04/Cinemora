import 'package:equatable/equatable.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';

class RankingsState extends Equatable {
  final List<RankingList> lists;

  /// A write the server rejected or never received. Rankings are mutated from
  /// several screens, so this is surfaced through the app-wide ScaffoldMessenger
  /// rather than by any one view.
  final String? mutationError;

  const RankingsState({required this.lists, this.mutationError});

  RankingsState copyWith({
    List<RankingList>? lists,
    String? mutationError,
    bool clearMutationError = false,
  }) =>
      RankingsState(
        lists: lists ?? this.lists,
        mutationError:
            clearMutationError ? null : (mutationError ?? this.mutationError),
      );

  int get totalRanked => lists.fold(0, (sum, l) => sum + l.entries.length);

  @override
  List<Object?> get props => [lists, mutationError];
}
