import 'dart:async';

import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/services/ble_service.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:awesome_board/widgets/custom_dialog.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class ProblemScreen extends StatefulWidget {
  final Problem problem;

  const ProblemScreen({
    Key key,
    this.problem,
  }) : super(key: key);
  @override
  _ProblemScreenState createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  final CustomTheme _theme = CustomTheme.getThemeFromStorage();
  final double holdsHorizontal = 11;
  final double holdsVertical = 18;
  String message = "";
  String imgPath = "";
  bool customBoard;
  bool liked;
  final BleService _bleService = BleService();
  StreamSubscription<BleInformationType> _bleSubscription;

  @override
  void dispose() async {
    super.dispose();
    await _bleSubscription.cancel();
    await _bleService.cleanup();
  }

  @override
  void initState() {
    liked = widget.problem.isLiked();
    customBoard = true;
    super.initState();
    _bleSubscription = _bleService.streamInformation.listen((event) {
      if (event == BleInformationType.deviceReady) {
        setState(() {});
      }
    });
    checkImage();
  }

  void checkImage() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = io.File(dir.path + "moon.png");
    if (await file.exists()) {
      imgPath = file.path;
    }
    setState(() {});
  }

  void sendToMoon() async {
    _bleService.writeData(widget.problem.holds);
  }

  void deleteProblem() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialogBox(
          title: "Löschen",
          descriptions: "Problem wirklich löschen ?",
          buttonText: "Ja",
        );
      },
    ).then((value) async {
      if (value == "okay") {
        var box = Hive.box<Problem>("customProblems");
        String id = widget.problem.strId;
        await box.delete(id);
      }
    });
  }

  void toggleLiked() {
    if (liked) {
      widget.problem.dislike();
      liked = false;
    } else {
      widget.problem.like();
      liked = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width - (20 + 16);
    double imgH = screenW * 1.54;
    Problem problem = this.widget.problem;
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              CustomAppBar(title: "Problem"),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _theme.secondBackground,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _theme.notifications,
                      blurRadius: 5,
                      spreadRadius: -2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bleService.finishedScanAndFoundDevice
                        ? Icon(Icons.check_circle, color: Colors.greenAccent)
                        : Icon(Icons.cancel, color: Colors.redAccent),
                    Icon(
                      Icons.bluetooth,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: 40,
                        color: liked ? Colors.pink : Colors.grey,
                      ),
                      onPressed: toggleLiked,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CustomCard(
                      padding: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            problem.getGradeString(),
                            style: TextStyle(color: _theme.linksColor),
                          ),
                          Text(
                            problem.name,
                            style: TextStyle(color: _theme.accentColor),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SickButton(
                          child: Icon(Icons.fullscreen_exit, color: _theme.foreground),
                          onPress: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        problem.holdsSetup == 999
                            ? SickButton(child: Icon(Icons.delete_outline, color: Colors.red), onPress: deleteProblem)
                            : SickButton(child: Icon(Icons.delete_outline, color: _theme.disabled), onPress: () {}),
                        SickButton(
                          child: Icon(Icons.swap_horiz, color: !customBoard ? Colors.yellow : Colors.blue),
                          onPress: () {
                            setState(() {
                              customBoard = !customBoard;
                              imgPath = customBoard ? "./assets/images/custom_moonboard.png" : "./assets/images/A_2016-B_2016-OS_2016_highRes.png";
                            });
                            if (customBoard) checkImage();
                          },
                        ),
                        SickButton(child: Icon(Icons.send, color: _theme.accentColor), onPress: sendToMoon),
                      ],
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
                            List<Hold> holds = problem.getHolds();
                            int hIn = holds.indexWhere((e) => Utils.convert2DTo1D(e.location, holdsHorizontal.toInt()) == index);
                            Color outlineColor = Colors.transparent;

                            if (hIn != -1) {
                              Hold h = holds[hIn];
                              switch (h.holdType) {
                                case HoldType.finishHold:
                                  outlineColor = Colors.redAccent;
                                  break;
                                case HoldType.startHold:
                                  outlineColor = Colors.greenAccent;
                                  break;
                                case HoldType.normalHold:
                                  outlineColor = Colors.blueAccent;
                                  break;
                              }
                            }

                            return CustomPaint(painter: DrawCircle(outlineColor));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
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
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 + 5, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
