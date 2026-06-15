import 'package:equatable/equatable.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';

class RankingDetailState extends Equatable {
  final List<RankingEntry> entries;

  const RankingDetailState({required this.entries});

  RankingDetailState copyWith({List<RankingEntry>? entries}) {
    return RankingDetailState(entries: entries ?? this.entries);
  }

  @override
  List<Object> get props => [entries];
}
