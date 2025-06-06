part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeEvent {}

class SetTheme extends ThemeEvent {
  final bool isDarkMode;

  const SetTheme({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}