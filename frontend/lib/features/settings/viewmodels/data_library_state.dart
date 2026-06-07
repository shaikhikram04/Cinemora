import 'package:equatable/equatable.dart';

class DataLibraryState extends Equatable {
  final bool cacheCleared;

  const DataLibraryState({this.cacheCleared = false});

  DataLibraryState copyWith({bool? cacheCleared}) {
    return DataLibraryState(cacheCleared: cacheCleared ?? this.cacheCleared);
  }

  @override
  List<Object> get props => [cacheCleared];
}
