import 'package:equatable/equatable.dart';

class AppearanceState extends Equatable {
  final int selectedTheme; // 0=dark, 1=light, 2=system

  const AppearanceState({this.selectedTheme = 0});

  AppearanceState copyWith({int? selectedTheme}) {
    return AppearanceState(selectedTheme: selectedTheme ?? this.selectedTheme);
  }

  @override
  List<Object> get props => [selectedTheme];
}
