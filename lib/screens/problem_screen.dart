import 'dart:async';
import 'dart:math';

import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/services/ble_service.dart';
import 'package:awesome_board/widgets/ble_status_builder.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:awesome_board/widgets/custom_dialog.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:math' as math;

class ProblemScreen extends StatefulWidget {
  final Problem problem;
  final List<Problem> problems;
  final bool fromHistory;

  const ProblemScreen({
    Key key,
    this.problem,
    this.problems,
    this.fromHistory = false,
  }) : super(key: key);
  @override
  _ProblemScreenState createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  final double holdsHorizontal = 11;
  final double holdsVertical = 18;
  Problem problem;
  String message = "";
  String imgPath = "";
  int currentHistoryIndex = 0;
  bool customBoard;
  bool liked;
  bool mirror;
  final BleService _bleService = BleService();
  List<Problem> history = [];
  ImageProvider brdImage;

  @override
  void dispose() async {
    super.dispose();
    await _bleService.cleanup();
  }

  @override
  void initState() {
    problem = this.widget.problem;
    this.widget.problems.remove(problem);
    liked = problem.isLiked();
    customBoard = true;
    mirror = false;
    history.add(problem);
    if (!this.widget.fromHistory) problem.addToHistory();
    super.initState();
    brdImage = AssetImage("./assets/images/custom_moonboard.png");
    checkImage();
  }

  void checkImage() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = io.File(dir.path + "/moon.png");
    if (customBoard) {
      if (await file.exists()) {
        brdImage = FileImage(file);
      } else {
        brdImage = AssetImage("./assets/images/custom_moonboard.png");
      }
    } else {
      brdImage = AssetImage("./assets/images/A_2016-B_2016-OS_2016_highRes.png");
    }
    setState(() {});
  }

  void sendToMoon() async {
    _bleService.writeData(mirror ? problem.mirrorHoldsIndexes() : problem.holds);
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
        String id = problem.strId;
        await box.delete(id);
      }
    });
  }

  void toggleLiked() {
    if (liked) {
      problem.dislike();
      liked = false;
    } else {
      problem.like();
      liked = true;
    }
    setState(() {});
  }

  void nextProblem() {
    if (this.widget.problems.isEmpty) return;
    setState(() {
      if (currentHistoryIndex == history.length - 1) {
        problem = this.widget.problems.removeAt(Random().nextInt(this.widget.problems.length));
        history.add(problem);
        if (!this.widget.fromHistory) problem.addToHistory();
        currentHistoryIndex = history.length - 1;
      } else {
        currentHistoryIndex++;
        problem = history[currentHistoryIndex];
      }
      liked = problem.isLiked();
      mirror = false;
    });
  }

  void previousProblem() {
    setState(() {
      if (currentHistoryIndex > 0) {
        currentHistoryIndex--;
        problem = history[currentHistoryIndex];
        liked = problem.isLiked();
        mirror = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width - (20 + 16);
    double imgH = screenW * 1.54;
    return BlocBuilder<ThemeBloc, CustomTheme>(builder: (context, _theme) {
      return Container(
        child: Column(
          children: [
            Stack(
              children: [
                CustomAppBar(title: "Problem"),
                BleStatusBuilder(bleState: _bleService.streamInformation),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text((currentHistoryIndex + 1).toString() + "/" + history.length.toString(),
                                    style: TextStyle(color: _theme.foreground)),
                                Expanded(
                                  child: Text(
                                    problem.getGradeString(),
                                    style: TextStyle(color: _theme.linksColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Row(
                                  children: [
                                    problem.suitedForCustomBoard()
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.greenAccent,
                                          )
                                        : SizedBox(),
                                    problem.mirrorSuitedForCustomBoard()
                                        ? Transform(
                                            alignment: Alignment.topCenter,
                                            transform: Matrix4.rotationY(math.pi),
                                            child: Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.yellowAccent,
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                Expanded(
                                  child: Text(
                                    problem.getSuffixName(),
                                    style: TextStyle(color: _theme.accentColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            problem.getPrefixMethod() == null
                                ? SizedBox()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: problem.methodIcons(_theme.foreground),
                                      ),
                                      Text(problem.getPrefixMethod(), style: TextStyle(color: _theme.foreground)),
                                    ],
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
                              customBoard = !customBoard;
                              checkImage();
                            },
                          ),
                          SickButton(child: Icon(Icons.send, color: _theme.accentColor), onPress: sendToMoon),
                        ],
                      ),
                      Center(
                        child: GestureDetector(
                          onDoubleTap: () {
                            setState(() => mirror = !mirror);
                            sendToMoon();
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity < 0) {
                              sendToMoon();
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity > 0) {
                              previousProblem();
                            } else if (details.primaryVelocity < 0) {
                              nextProblem();
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
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
                                    List<Hold> holds = mirror ? problem.mirrorHolds() : problem.getHolds();
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
                              Positioned(
                                top: 8,
                                child: mirror
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Transform(
                                          alignment: Alignment.topCenter,
                                          transform: Matrix4.rotationY(math.pi),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.yellowAccent,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ),
                            ],
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
    });
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
