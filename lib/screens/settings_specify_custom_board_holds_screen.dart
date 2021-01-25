import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsSpecifyCustomHoldsScreen extends StatefulWidget {
  @override
  _SettingsSpecifyCustomHoldsScreenState createState() => _SettingsSpecifyCustomHoldsScreenState();
}

class _SettingsSpecifyCustomHoldsScreenState extends State<SettingsSpecifyCustomHoldsScreen> {
  CustomTheme _theme = CustomTheme.getThemeFromStorage();
  final double holdsHorizontal = 11;
  final double holdsVertical = 18;
  String message = "";
  String imgPath = "./assets/images/custom_moonboard.png";
  List<int> holds = [];
  Box _box;

  bool customBoard = true;

  @override
  initState() {
    super.initState();
    _box = Hive.box("settings");
    List<int> flippedIndexHolds = Problem.getCustomHoldIndexes();
    var flippedHolds = flippedIndexHolds.map((e) => Utils.convert1DTo2D(e, 11)).toList();
    flippedHolds = flippedHolds.map((e) => Utils.flipOverY(e, 17)).toList();
    holds = flippedHolds.map((e) => Utils.convert2DTo1D(e, 11)).toList();
  }

  addHold(int index) {
    setState(() {
      if (holds.contains(index)) {
        holds.remove(index);
      } else {
        holds.add(index);
      }
    });
  }

  clearHolds() {
    setState(() {
      holds.clear();
    });
  }

  apply() async {
    var flippedHolds = holds.map((e) => Utils.convert1DTo2D(e, 11)).toList();
    flippedHolds = flippedHolds.map((e) => Utils.flipOverY(e, 17)).toList();
    var flippedIndexHolds = flippedHolds.map((e) => Utils.convert2DTo1D(e, 11)).toList();
    await _box.put("customHoldIndexes", flippedIndexHolds);
    Navigator.of(context).pop("save");
  }

  cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width - (20 + 16);
    double imgH = screenW * 1.54;
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SickButton(
                  child: Icon(
                    Icons.fullscreen_exit,
                    color: _theme.foreground,
                  ),
                  onPress: cancel,
                ),
                SickButton(
                  child: Icon(Icons.swap_horiz, color: !customBoard ? Colors.yellow : Colors.blue),
                  onPress: () {
                    setState(() {
                      customBoard = !customBoard;
                      imgPath = customBoard ? "./assets/images/custom_moonboard.png" : "./assets/images/A_2016-B_2016-OS_2016_highRes.png";
                    });
                  },
                ),
                SickButton(
                  child: Icon(Icons.check_circle, color: Colors.greenAccent),
                  onPress: apply,
                ),
                SickButton(
                    child: Icon(
                      Icons.clear,
                      color: Colors.orangeAccent,
                    ),
                    onPress: clearHolds),
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
                  image: AssetImage(imgPath),
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
                  Color outlineColor = Colors.transparent;

                  if (holds.contains(index)) {
                    outlineColor = Colors.white;
                    if (!customBoard) {
                      outlineColor = Colors.black;
                    }
                    outlineColor = outlineColor.withOpacity(0.7);
                  }

                  return GestureDetector(
                    onTap: () => addHold(index),
                    child: CustomPaint(painter: DrawCircle(outlineColor)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawCircle extends CustomPainter {
  Paint _paint;

  DrawCircle(Color color) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 + 2, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
