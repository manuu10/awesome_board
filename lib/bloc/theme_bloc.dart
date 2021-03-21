import 'package:awesome_board/models/custom_theme.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final CustomTheme theme;

  ChangeThemeEvent(this.theme);
}

class ThemeBloc extends Bloc<ThemeEvent, CustomTheme> {
  ThemeBloc() : super(CustomTheme.getThemeFromStorage());

  @override
  Stream<CustomTheme> mapEventToState(ThemeEvent event) async* {
    if (event is ChangeThemeEvent) {
      yield event.theme;
    }
  }
}
