import 'package:awesome_board/models/custom_theme.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, buttonText;

  final CustomTheme theme = CustomTheme.getThemeFromStorage();

  CustomDialogBox({
    Key key,
    this.title,
    this.descriptions,
    this.buttonText,
  }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
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
            color: widget.theme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.theme.contrast,
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
                widget.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: widget.theme.foreground),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions,
                style: TextStyle(fontSize: 14, color: widget.theme.foreground),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Divider(
                thickness: 1,
                color: widget.theme.highlight,
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
                      style: TextStyle(fontSize: 18, color: widget.theme.foreground),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop("okay");
                    },
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(fontSize: 18, color: widget.theme.foreground),
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
