import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:flutter/material.dart';

class SaveDialog extends StatefulWidget {
  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  CustomTheme _theme = CustomTheme.getThemeFromStorage();
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
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _theme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _theme.contrast,
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _theme.foreground),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: txtAuth,
                style: TextStyle(color: _theme.foreground),
                cursorColor: _theme.accentColor,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: _theme.disabled),
                  hintText: "Author",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: _theme.accentColor,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: txtName,
                style: TextStyle(color: _theme.foreground),
                cursorColor: _theme.accentColor,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: _theme.disabled),
                  hintText: "Name",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: _theme.accentColor,
                    ),
                  ),
                ),
              ),
              DropdownButton<int>(
                dropdownColor: _theme.secondBackground,
                style: TextStyle(color: _theme.foreground),
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
                color: _theme.highlight,
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
                      style: TextStyle(fontSize: 18, color: _theme.foreground),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop<List>([txtAuth.text, txtName.text, _selectedGrade]);
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 18, color: _theme.foreground),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
