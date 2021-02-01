import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/path_generator.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/services/ble_service.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:awesome_board/widgets/gen_random_route_dialog.dart';
import 'package:awesome_board/widgets/save_dialog.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class CreateProblemScreen extends StatefulWidget {
  @override
  _CreateProblemScreenState createState() => _CreateProblemScreenState();
}

class _CreateProblemScreenState extends State<CreateProblemScreen> {
  final CustomTheme _theme = CustomTheme.getThemeFromStorage();
  final double holdsHorizontal = 11;
  final double holdsVertical = 18;
  String message = "";
  List<Hold> holds = [];
  HoldType _curHoldType = HoldType.startHold;
  PathGenerator pathGen = PathGenerator();
  StreamSubscription _liveRandomSub;
  StreamSubscription _liveRandomFinishSub;
  StreamSubscription _bleSubscription;
  BleService _bleService = BleService();

  bool customBoard = true;
  String imgPath = "./assets/images/custom_moonboard.png";

  @override
  void dispose() async {
    super.dispose();
    await _liveRandomFinishSub.cancel();
    await _liveRandomSub.cancel();
    await _bleSubscription.cancel();
    await pathGen.dispose();
    await _bleService.cleanup();
  }

  @override
  void initState() {
    super.initState();
    _bleSubscription = _bleService.streamInformation.listen((event) {
      if (event == BleInformationType.deviceReady) {
        setState(() {});
      }
    });
    _liveRandomSub = pathGen.stream.listen((event) {
      var temp = event.map((e) => Hold(holdType: HoldType.normalHold, location: Utils.flipOverY(e, 17))).toList();
      holds = temp;
      sendToMoon();
      setState(() {});
    });
    _liveRandomFinishSub = pathGen.streamFinished.listen((event) {
      if (event) {
        holds[holds.length - 1].holdType = HoldType.finishHold;
        holds[0].holdType = HoldType.startHold;
        sendToMoon();
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

  void save(String author, String name, int grade) async {
    int holdSetup = customBoard ? 999 : null;
    Problem p = Problem(
      author: author,
      name: name,
      holds: convertHoldsToString(),
      grade: grade,
      holdsSetup: holdSetup,
      dateTime: DateTime.now(),
    );
    var box = Hive.box<Problem>("customProblems");
    await box.put(p.strId, p);
  }

  void openSaveDialog() {
    showDialog<List>(
      context: context,
      builder: (BuildContext context) {
        return SaveDialog();
      },
    ).then(
      (value) {
        if (value is List && value != null) {
          if (value.isNotEmpty) {
            if (value[0] != null && value[1] != null && value[2] != null) {
              save(value[0], value[1], value[2]);
            }
          }
        }
      },
    );
  }

  void sendToMoon() {
    writeData(convertHoldsToString());
  }

  String convertHoldsToString() {
    List<int> intHolds = [];
    for (var e in holds) {
      var ee = Hold(location: e.location, holdType: e.holdType);
      ee.location = Utils.flipOverY(ee.location, holdsVertical.toInt() - 1);
      intHolds.add(Utils.convert2DTo1D(ee.location, holdsHorizontal.toInt()));
      switch (ee.holdType) {
        case HoldType.finishHold:
          intHolds.add(2);
          break;
        case HoldType.startHold:
          intHolds.add(1);
          break;
        case HoldType.normalHold:
          intHolds.add(0);
          break;
      }
    }
    return json.encode(intHolds);
  }

  writeData(String data) {
    _bleService.writeData(data);
  }

  void addHold(int index) {
    pathGen.cancelTimer();
    Point<int> p = Utils.convert1DTo2D(index, holdsHorizontal.toInt());
    Hold h = Hold(holdType: _curHoldType, location: p);
    if (holds.contains(h)) {
      holds.remove(h);
    } else if (holds.where((e) => e.location == p).length > 0) {
      holds.firstWhere((e) => e.location == p).holdType = _curHoldType;
    } else {
      holds.add(h);
    }
    updateMessage();
    sendToMoon();
    setState(() {});
  }

  void updateMessage() {
    message = "";
    for (var e in holds) {
      var ee = Hold(location: e.location, holdType: e.holdType);
      ee.location = Utils.flipOverY(ee.location, holdsVertical.toInt() - 1);
      message += Utils.convert2DTo1D(ee.location, holdsHorizontal.toInt()).toString() + ", ";
    }
  }

  void clearHolds() {
    setState(() {
      holds = [];
      updateMessage();
    });
    sendToMoon();
  }

  void shuffleHolds() async {
    showDialog<List>(
      context: context,
      builder: (BuildContext context) {
        return GenereateRandomRouteDialog();
      },
    ).then(
      (value) {
        if (value is List && value != null) {
          if (value.isNotEmpty) {
            int length = int.tryParse(value[0]);
            int distance = int.tryParse(value[1]);
            if (length != null && distance != null) {
              pathGen.createRandom(amount: length, distance: distance);
            }
          }
        }
      },
    );
    /* setState(() {
      holds = Problem.convertHoldStringToList(json.encode(Problem.createRandomHoldList()));
      updateMessage();
    });
    sendToMoon(); */
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width - (20 + 20);
    double imgH = screenW * 1.54;
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              CustomAppBar(title: "Create"),
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
            ],
          ),
          Text(
            message,
            style: TextStyle(color: _theme.foreground),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SickButton(
                          child: Icon(
                            Icons.save,
                            color: Colors.orange,
                          ),
                          onPress: openSaveDialog,
                        ),
                        SickButton(
                          child: Icon(
                            Icons.shuffle,
                            color: _theme.foreground,
                          ),
                          onPress: shuffleHolds,
                        ),
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SickButton(
                          child: Icon(
                            _curHoldType == HoldType.startHold ? Icons.lens_outlined : Icons.lens,
                            color: Colors.greenAccent,
                          ),
                          onPress: () {
                            setState(() {
                              _curHoldType = HoldType.startHold;
                            });
                          },
                        ),
                        SickButton(
                          child: Icon(
                            _curHoldType == HoldType.normalHold ? Icons.lens_outlined : Icons.lens,
                            color: Colors.blueAccent,
                          ),
                          onPress: () {
                            setState(() {
                              _curHoldType = HoldType.normalHold;
                            });
                          },
                        ),
                        SickButton(
                          child: Icon(
                            _curHoldType == HoldType.finishHold ? Icons.lens_outlined : Icons.lens,
                            color: Colors.redAccent,
                          ),
                          onPress: () {
                            setState(() {
                              _curHoldType = HoldType.finishHold;
                            });
                          },
                        ),
                        SickButton(
                          child: Icon(
                            Icons.clear,
                            color: Colors.orange,
                          ),
                          onPress: clearHolds,
                        ),
                      ],
                    ),
                    CustomCard(
                      padding: 10,
                      child: Container(
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
