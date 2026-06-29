import 'package:equatable/equatable.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';

class RankingsState extends Equatable {
  final List<RankingList> lists;

  const RankingsState({required this.lists});

  RankingsState copyWith({List<RankingList>? lists}) =>
      RankingsState(lists: lists ?? this.lists);

  int get totalRanked => lists.fold(0, (sum, l) => sum + l.entries.length);

  @override
  List<Object> get props => [lists];
}
