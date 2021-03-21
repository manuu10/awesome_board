import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class GenereateRandomRouteDialog extends StatefulWidget {
  @override
  _GenereateRandomRouteDialogState createState() => _GenereateRandomRouteDialogState();
}

class _GenereateRandomRouteDialogState extends State<GenereateRandomRouteDialog> {
  Box _box;
  TextEditingController txtLength = TextEditingController();
  TextEditingController txtDistance = TextEditingController();

  @override
  void initState() {
    super.initState();
    _box = Hive.box("settings");
    txtLength.text = _box.get("randomProblemLength") ?? "";
    txtDistance.text = _box.get("randomProblemDistance") ?? "";
  }

  void cacheInput() {
    _box.put("randomProblemLength", txtLength.text);
    _box.put("randomProblemDistance", txtDistance.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, theme) {
        return Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: theme.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.contrast,
                    blurRadius: 5,
                    spreadRadius: -2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Problem generieren",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: theme.foreground),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtLength,
                          style: TextStyle(color: theme.foreground),
                          cursorColor: theme.accentColor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: theme.disabled),
                            labelText: "Anzahl Griffe",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: txtDistance,
                          style: TextStyle(color: theme.foreground),
                          cursorColor: theme.accentColor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: theme.disabled),
                            labelText: "Max Entfernung Griffe",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Divider(
                    thickness: 1,
                    color: theme.highlight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 18, color: theme.foreground),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          cacheInput();
                          Navigator.of(context).pop<List>([txtLength.text, txtDistance.text]);
                        },
                        child: Text(
                          "Gogogogo",
                          style: TextStyle(fontSize: 18, color: theme.foreground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
