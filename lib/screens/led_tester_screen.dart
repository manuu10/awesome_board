import 'dart:async';

import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/services/ble_service.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:awesome_board/widgets/esp32_mode.dart';
import 'package:awesome_board/widgets/gradient_icon.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LedTesterScreen extends StatefulWidget {
  const LedTesterScreen({
    Key key,
  }) : super(key: key);
  @override
  _LedTesterScreenState createState() => _LedTesterScreenState();
}

class _LedTesterScreenState extends State<LedTesterScreen> {
  final BleService _bleService = BleService();
  StreamSubscription<BleInformationType> _bleSubscription;

  @override
  void dispose() async {
    super.dispose();
    _bleService.stopReading();
    await _bleSubscription.cancel();
    await _bleService.cleanup();
  }

  @override
  void initState() {
    super.initState();
    _bleService.startReading();
    _bleSubscription = _bleService.streamInformation.listen((event) {
      if (event == BleInformationType.deviceReady) {
        setState(() {});
      }
    });
  }

  void switchToMoonBoard() => _bleService.writeData("moonMode");
  void switchToLedTester() => _bleService.writeData("testMode");
  void rainbowMode() => _bleService.writeData("rainbow");
  void trailingMode() => _bleService.writeData("trailing");
  void nothingMode() => _bleService.writeData("nothing");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, _theme) {
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
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Esp32Mode(esp32Read: _bleService.streamRead),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: CustomCard(
                                onPress: switchToMoonBoard,
                                headChild: Icon(
                                  Icons.grid_on,
                                  color: Colors.lightGreenAccent,
                                ),
                                child: Text(
                                  "MoonBoard Mode",
                                  style: TextStyle(color: _theme.foreground),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: CustomCard(
                                onPress: switchToLedTester,
                                headChild: Icon(
                                  Icons.lightbulb_outlined,
                                  color: Colors.lightBlueAccent,
                                ),
                                child: Text(
                                  "LED Testing",
                                  style: TextStyle(color: _theme.foreground),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GridView.count(
                          physics: ScrollPhysics(),
                          padding: EdgeInsets.all(10),
                          shrinkWrap: true,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 3,
                          children: [
                            SickButton(
                              child: Icon(
                                Icons.cancel,
                                size: 50,
                                color: _theme.foreground,
                              ),
                              onPress: nothingMode,
                            ),
                            SickButton(
                              onPress: rainbowMode,
                              child: GradientIcon(
                                Icons.color_lens,
                                50,
                                LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red,
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.indigo,
                                    Color(0xffee82ee),
                                  ],
                                ),
                              ),
                            ),
                            SickButton(
                              child: Icon(
                                Icons.sort,
                                size: 50,
                                color: _theme.foreground,
                              ),
                              onPress: trailingMode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
