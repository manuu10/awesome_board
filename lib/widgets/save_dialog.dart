import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveDialog extends StatefulWidget {
  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  int _selectedGrade;

  TextEditingController txtAuth = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtGrade = TextEditingController();
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
                    "Problem speichern",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: theme.foreground),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: txtAuth,
                    style: TextStyle(color: theme.foreground),
                    cursorColor: theme.accentColor,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: theme.disabled),
                      hintText: "Author",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: txtName,
                    style: TextStyle(color: theme.foreground),
                    cursorColor: theme.accentColor,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: theme.disabled),
                      hintText: "Name",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                  ),
                  DropdownButton<int>(
                    dropdownColor: theme.secondBackground,
                    style: TextStyle(color: theme.foreground),
                    value: _selectedGrade,
                    items: Problem.getAllGradeNumbers().map((value) {
                      return new DropdownMenuItem<int>(
                        value: value,
                        child: new Text(Problem.convertGradeString(value)),
                      );
                    }).toList(),
                    onChanged: (newval) {
                      setState(() {
                        _selectedGrade = newval;
                      });
                    },
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
                          Navigator.of(context).pop<List>([txtAuth.text, txtName.text, _selectedGrade]);
                        },
                        child: Text(
                          "Save",
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
