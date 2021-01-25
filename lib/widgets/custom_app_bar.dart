import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';

class CustomAppBar extends StatelessWidget {
  final CustomTheme _theme = CustomTheme.getThemeFromStorage();
  final String title;

  CustomAppBar({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _theme.secondBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: _theme.notifications,
            spreadRadius: -3,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
                shadows: [
                  Shadow(color: _theme.foreground, blurRadius: 50),
                ],
              ),
            ),
            GradientText(
              title,
              gradient: _theme.linearGradient,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
