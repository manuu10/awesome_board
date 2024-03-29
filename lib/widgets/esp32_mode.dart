import 'dart:async';

import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Esp32Mode extends StatefulWidget {
  final Stream esp32Read;

  const Esp32Mode({Key key, this.esp32Read}) : super(key: key);
  @override
  _Esp32ModeState createState() => _Esp32ModeState();
}

class _Esp32ModeState extends State<Esp32Mode> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: this.widget.esp32Read,
      //Mode 1: MoonBoard
      //Mode 2: LED Testing
      initialData: "0",
      builder: (context, snapshot) {
        print(snapshot.data);
        Color col = Colors.grey;
        String text = "Loading ..." + snapshot.data;
        if (snapshot.data == "1") {
          col = Colors.lightGreenAccent;
          text = "MoonBoard Mode";
        } else if (snapshot.data == "2") {
          col = Colors.lightBlueAccent;
          text = "LED Testing";
        }

        return BlocBuilder<ThemeBloc, CustomTheme>(
          builder: (context, theme) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: col,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(color: col),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
