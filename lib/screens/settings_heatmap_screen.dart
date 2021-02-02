import 'dart:math';

import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/widgets/sick_button.dart';

class SettingsHeatmapScreen extends StatefulWidget {
  @override
  _SettingsHeatmapScreenState createState() => _SettingsHeatmapScreenState();
}

class _SettingsHeatmapScreenState extends State<SettingsHeatmapScreen> {
  CustomTheme _theme = CustomTheme.getThemeFromStorage();
  final double holdsHorizontal = 11;
  final double holdsVertical = 18;
  String message = "";
  String imgPath = "./assets/images/custom_moonboard.png";
  bool showNumbers = false;
  bool onlyNonPlaced = false;
  ImageProvider brdImage;

  Map<int, int> holds;
  int _max = 0;
  int _min = 0;

  @override
  initState() {
    super.initState();
    brdImage = AssetImage(imgPath);
    refreshSelected();
    checkImage();
  }

  void refreshSelected() {
    var mapp = Utils.holdHeatMap(Utils.fetchProblemUseSettings(""));
    if (onlyNonPlaced) {
      var holdscustom = Problem.getCustomHoldIndexes();
      mapp.removeWhere((key, value) => holdscustom.contains(key));
    }
    var flippedHolds = mapp.map((k, v) => MapEntry(Utils.convert1DTo2D(k, 11), v));
    flippedHolds = flippedHolds.map((k, v) => MapEntry(Utils.flipOverY(k, 17), v));
    holds = flippedHolds.map((k, v) => MapEntry(Utils.convert2DTo1D(k, 11), v));
    _max = holds.values.reduce(max);
    _min = holds.values.reduce(min);
    setState(() {});
  }

  void checkImage() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = io.File(dir.path + "/moon.png");
    if (await file.exists()) {
      brdImage = FileImage(file);
    } else {
      brdImage = AssetImage(imgPath);
    }

    setState(() {});
  }

  cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width - (20 + 16);
    double imgH = screenW * 1.54;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: CustomCard(
                      headChild: Icon(
                        Icons.format_list_numbered_sharp,
                        color: _theme.foreground,
                      ),
                      padding: 3,
                      child: Switch(
                          activeColor: _theme.accentColor,
                          value: showNumbers,
                          onChanged: (val) {
                            setState(() {
                              showNumbers = val;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      headChild: Icon(
                        Icons.grid_off,
                        color: _theme.foreground,
                      ),
                      padding: 3,
                      child: Switch(
                          activeColor: _theme.accentColor,
                          value: onlyNonPlaced,
                          onChanged: (val) {
                            setState(() {
                              onlyNonPlaced = val;
                              refreshSelected();
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: SickButton(
                      child: Icon(
                        Icons.fullscreen_exit,
                        color: _theme.foreground,
                      ),
                      onPress: cancel,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding: EdgeInsets.only(
                  top: (imgH / 16.8),
                  left: (screenW / 9.5),
                  right: (screenW / 21.5),
                  bottom: (imgH / 26),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: brdImage,
                    fit: BoxFit.cover,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: (holdsHorizontal * holdsVertical).toInt(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: holdsHorizontal.toInt(),
                  ),
                  itemBuilder: (context, index) {
                    int value = holds.keys.contains(index) ? holds[index] : -1;
                    return GestureDetector(
                      child: CustomPaint(painter: DrawCircle(_min, _max, value, showNumbers)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawCircle extends CustomPainter {
  Paint _paint;
  int _value;
  bool _numbers;
  DrawCircle(int minimum, int maximum, int value, bool numbers) {
    _paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    if (value != -1) {
      _paint.color = _heatMap(minimum, maximum, value).withOpacity(0.6);
    }
    _value = value;
    _numbers = numbers;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
    canvas.drawRect(rect, _paint);
    if (_value != -1 && _numbers) {
      TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.white, fontSize: size.width / 3, shadows: [
          Shadow(blurRadius: 10, color: Colors.black),
        ]),
        text: _value.toString(),
      );
      TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, new Offset(1, 1));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  static List<ColorPoint> color = [
    ColorPoint(Color.fromRGBO(0, 0, 255, 1), 0),
    ColorPoint(Color.fromRGBO(0, 255, 255, 1), 0.25),
    ColorPoint(Color.fromRGBO(0, 255, 0, 1), 0.5),
    ColorPoint(Color.fromRGBO(255, 255, 0, 1), 0.75),
    ColorPoint(Color.fromRGBO(255, 0, 0, 1), 1),
  ];

  Color _heatMap(int minimum, int maximum, int ratio) {
    double value = 2 * (ratio - minimum) / (maximum - minimum);
    double red;
    double green;
    double blue;
    if (color.length == 0) return Colors.transparent;

    for (int i = 0; i < color.length; i++) {
      ColorPoint currC = color[i];
      if (value < currC.val) {
        ColorPoint prevC = color[max(0, i - 1)];
        double valueDiff = (prevC.val - currC.val);
        double fractBetween = (valueDiff == 0) ? 0 : (value - currC.val) / valueDiff;
        red = (prevC.col.red - currC.col.red) * fractBetween + currC.col.red;
        green = (prevC.col.green - currC.col.green) * fractBetween + currC.col.green;
        blue = (prevC.col.blue - currC.col.blue) * fractBetween + currC.col.blue;
        return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
      }
    }
    red = color.last.col.red.toDouble();
    green = color.last.col.green.toDouble();
    blue = color.last.col.blue.toDouble();
    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }
}

class ColorPoint {
  Color col;
  double val;
  ColorPoint(
    this.col,
    this.val,
  );
}
