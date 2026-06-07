import 'package:equatable/equatable.dart';

class CreateSessionState extends Equatable {
  final String contentType;
  final List<String> selectedGenres;

  const CreateSessionState({
    this.contentType = 'Both',
    this.selectedGenres = const [],
  });

  CreateSessionState copyWith({
    String? contentType,
    List<String>? selectedGenres,
  }) {
    return CreateSessionState(
      contentType: contentType ?? this.contentType,
      selectedGenres: selectedGenres ?? this.selectedGenres,
    );
  }

  @override
  List<Object> get props => [contentType, selectedGenres];
}
