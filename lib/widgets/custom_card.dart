import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Widget headChild;
  final Function onPress;
  final double padding;

  final borderRadius = BorderRadius.only(
    topRight: Radius.circular(20),
    topLeft: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );
  CustomCard({
    Key key,
    @required this.child,
    this.onPress,
    this.headChild,
    this.padding = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, theme) {
        return Stack(
          children: [
            GestureDetector(
              onTap: onPress,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(padding),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: theme.secondBackground,
                  boxShadow: [
                    BoxShadow(
                      color: theme.notifications,
                      blurRadius: 5,
                      spreadRadius: -2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            headChild == null
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: headChild is Text ? BoxShape.rectangle : BoxShape.circle,
                      color: theme.contrast,
                      borderRadius: headChild is Text ? BorderRadius.circular(10) : null,
                    ),
                    child: headChild,
                  ),
          ],
        );
      },
    );
  }
}
