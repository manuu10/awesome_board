import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SickButton extends StatelessWidget {
  final Widget child;
  final Function onPress;
  SickButton({
    Key key,
    @required this.child,
    @required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, theme) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.buttons,
            boxShadow: [
              BoxShadow(
                color: theme.notifications,
                blurRadius: 7,
                spreadRadius: -5,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: FlatButton(
            padding: EdgeInsets.all(8),
            shape: CircleBorder(),
            child: child,
            onPressed: onPress,
          ),
        );
      },
    );
  }
}
