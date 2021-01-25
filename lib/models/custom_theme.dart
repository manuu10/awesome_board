import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class CustomTheme {
  static List<CustomTheme> themes = [
    PalenightTheme(),
    DarkerTheme(),
    DraculaTheme(),
    LightTheme(),
  ];

  static CustomTheme getThemeFromStorage() {
    var box = Hive.box("settings");
    var theme = themes.firstWhere(
      (e) => e.themeName == box.get("theme"),
      orElse: () {
        return PalenightTheme();
      },
    );
    return theme;
  }

  String themeName;

  //below should be used for ui as background colors
  Color background;
  Color foreground;
  Color text;
  Color selectionBackground;
  Color selectionForeground;
  Color buttons;
  Color secondBackground;
  Color disabled;
  Color contrast;
  Color active;
  Color border;
  Color highlight;
  Color tree;
  Color notifications;
  Color accentColor;
  Color excludedFilesColor;
  Color commentsColor;
  //below can be used for foreground colors
  Color linksColor;
  Color functionsColor;
  Color keywordsColor;
  Color tagsColor;
  Color stringsColor;
  Color operatorsColor;
  Color attributesColor;
  Color numbersColor;
  Color parametersColor;
  LinearGradient get linearGradient => LinearGradient(
        colors: <Color>[
          this.operatorsColor,
          this.stringsColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  LinearGradient get secondaryLinearGradient => LinearGradient(
        colors: <Color>[
          this.tagsColor,
          this.attributesColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class PalenightTheme extends CustomTheme {
  @override
  String get themeName => "Palenight";
  @override
  Color get background => Color(0xff292D3E);
  @override
  Color get foreground => Color(0xffA6ACCD);
  @override
  Color get text => Color(0xff676E95);
  @override
  Color get selectionBackground => Color(0xff3C435E);
  @override
  Color get selectionForeground => Color(0xffFFFFFF);
  @override
  Color get buttons => Color(0xff303348);
  @override
  Color get secondBackground => Color(0xff34324a);
  @override
  Color get disabled => Color(0xff515772);
  @override
  Color get contrast => Color(0xff202331);
  @override
  Color get active => Color(0xff414863);
  @override
  Color get border => Color(0xff2b2a3e);
  @override
  Color get highlight => Color(0xff444267);
  @override
  Color get tree => Color(0xff676E95);
  @override
  Color get notifications => Color(0xff202331);
  @override
  Color get accentColor => Color(0xffab47bc);
  @override
  Color get excludedFilesColor => Color(0xff2f2e43);
  @override
  Color get commentsColor => Color(0xff676E95);
  @override
  Color get linksColor => Color(0xff80cbc4);
  @override
  Color get functionsColor => Color(0xff82aaff);
  @override
  Color get keywordsColor => Color(0xffc792ea);
  @override
  Color get tagsColor => Color(0xfff07178);
  @override
  Color get stringsColor => Color(0xffc3e88d);
  @override
  Color get operatorsColor => Color(0xff89ddff);
  @override
  Color get attributesColor => Color(0xffffcb6b);
  @override
  Color get numbersColor => Color(0xfff78c6c);
  @override
  Color get parametersColor => Color(0xfff78c6c);
}

class LightTheme extends CustomTheme {
  @override
  String get themeName => "Light";
  @override
  Color get background => Color(0xffFAFAFA);
  @override
  Color get foreground => Color(0xff546E7A);
  @override
  Color get text => Color(0xff94A7B0);
  @override
  Color get selectionBackground => Color(0xff80CBC4);
  @override
  Color get selectionForeground => Color(0xff546e7a);
  @override
  Color get buttons => Color(0xffF3F4F5);
  @override
  Color get secondBackground => Color(0xffeae8e8);
  @override
  Color get disabled => Color(0xffD2D4D5);
  @override
  Color get contrast => Color(0xffF4F4F4);
  @override
  Color get active => Color(0xffE7E7E8);
  @override
  Color get border => Color(0xffd3e1e8);
  @override
  Color get highlight => Color(0xffE7E7E8);
  @override
  Color get tree => Color(0xff80CBC4);
  @override
  Color get notifications => Color(0xffeae8e8);
  @override
  Color get accentColor => Color(0xff00BCD4);
  @override
  Color get excludedFilesColor => Color(0xffeae8e8);
  @override
  Color get commentsColor => Color(0xffAABFC9);
  @override
  Color get linksColor => Color(0xff39ADB5);
  @override
  Color get functionsColor => Color(0xff6182B8);
  @override
  Color get keywordsColor => Color(0xff7C4DFF);
  @override
  Color get tagsColor => Color(0xffE53935);
  @override
  Color get stringsColor => Color(0xff91B859);
  @override
  Color get operatorsColor => Color(0xff39ADB5);
  @override
  Color get attributesColor => Color(0xffF6A434);
  @override
  Color get numbersColor => Color(0xffF76D47);
  @override
  Color get parametersColor => Color(0xffF76D47);
}

class DarkerTheme extends CustomTheme {
  @override
  String get themeName => "Darker";
  @override
  Color get background => Color(0xff212121);
  @override
  Color get foreground => Color(0xffB0BEC5);
  @override
  Color get text => Color(0xff727272);
  @override
  Color get selectionBackground => Color(0xff353535);
  @override
  Color get selectionForeground => Color(0xffFFFFFF);
  @override
  Color get buttons => Color(0xff2A2A2A);
  @override
  Color get secondBackground => Color(0xff292929);
  @override
  Color get disabled => Color(0xff474747);
  @override
  Color get contrast => Color(0xff1A1A1A);
  @override
  Color get active => Color(0xff323232);
  @override
  Color get border => Color(0xff292929);
  @override
  Color get highlight => Color(0xff3F3F3F);
  @override
  Color get tree => Color(0xff323232);
  @override
  Color get notifications => Color(0xff1A1A1A);
  @override
  Color get accentColor => Color(0xffFF9800);
  @override
  Color get excludedFilesColor => Color(0xff323232);
  @override
  Color get commentsColor => Color(0xff616161);
  @override
  Color get linksColor => Color(0xff80cbc4);
  @override
  Color get functionsColor => Color(0xff82aaff);
  @override
  Color get keywordsColor => Color(0xffc792ea);
  @override
  Color get tagsColor => Color(0xfff07178);
  @override
  Color get stringsColor => Color(0xffc3e88d);
  @override
  Color get operatorsColor => Color(0xff89ddff);
  @override
  Color get attributesColor => Color(0xffffcb6b);
  @override
  Color get numbersColor => Color(0xfff78c6c);
  @override
  Color get parametersColor => Color(0xfff78c6c);
}

class DraculaTheme extends CustomTheme {
  @override
  String get themeName => "Dracula";
  @override
  Color get background => Color(0xff282A36);
  @override
  Color get foreground => Color(0xffF8F8F2);
  @override
  Color get text => Color(0xff6272A4);
  @override
  Color get selectionBackground => Color(0xff44475A);
  @override
  Color get selectionForeground => Color(0xff8BE9FD);
  @override
  Color get buttons => Color(0xff393C4B);
  @override
  Color get secondBackground => Color(0xff222326);
  @override
  Color get disabled => Color(0xff6272A4);
  @override
  Color get contrast => Color(0xff191A21);
  @override
  Color get active => Color(0xff44475A);
  @override
  Color get border => Color(0xff21222C);
  @override
  Color get highlight => Color(0xff6272A4);
  @override
  Color get tree => Color(0xff44475A);
  @override
  Color get notifications => Color(0xff1D2228);
  @override
  Color get accentColor => Color(0xffFF79C5);
  @override
  Color get excludedFilesColor => Color(0xff34353D);
  @override
  Color get commentsColor => Color(0xff6272A4);
  @override
  Color get linksColor => Color(0xffF1FA8C);
  @override
  Color get functionsColor => Color(0xff50FA78);
  @override
  Color get keywordsColor => Color(0xffFF79C6);
  @override
  Color get tagsColor => Color(0xffFF79C6);
  @override
  Color get stringsColor => Color(0xffF1FA8C);
  @override
  Color get operatorsColor => Color(0xffFF79C6);
  @override
  Color get attributesColor => Color(0xff50FA7B);
  @override
  Color get numbersColor => Color(0xffBD93F9);
  @override
  Color get parametersColor => Color(0xffFFB86C);
}
