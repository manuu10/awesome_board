import 'dart:io';

import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/screens/led_tester_screen.dart';
import 'package:awesome_board/screens/settings_heatmap_screen.dart';
import 'package:awesome_board/screens/settings_specify_custom_board_holds_screen.dart';
import 'package:awesome_board/screens/settings_specify_holds_screen.dart';
import 'package:awesome_board/services/httpService.dart';
import 'package:awesome_board/services/json_service.dart';
import 'package:awesome_board/services/sqlite_service.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:awesome_board/widgets/gradient_icon.dart';
import 'package:awesome_board/widgets/sick_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CustomTheme _theme = CustomTheme.getThemeFromStorage();
  SQLiteService sqLiteService = SQLiteService();
  List<int> grades = [];
  String refreshMsg = "Refresh Problems from Database";
  String refreshMsgJson = "Refresh Problems from Json File";
  String strSpecifiedHolds = "";
  Box _box;

  String themeName = "";
  bool showCustomProblems;
  bool onlyCustomHolds;
  bool mirrorCustomHolds;
  bool showDatabaseProblems;
  bool showJsonFileProblems;
  bool containsSpecifiedHolds;
  bool onlyFavorites;

  @override
  void initState() {
    super.initState();
    _box = Hive.box("settings");
    grades = _box.get("grades") ?? [];
    showCustomProblems = _box.get("showCustomProblems") ?? false;
    showDatabaseProblems = _box.get("showDatabaseProblems") ?? false;
    showJsonFileProblems = _box.get("showJsonFileProblems") ?? false;
    onlyCustomHolds = _box.get("onlyCustomHolds") ?? false;
    mirrorCustomHolds = _box.get("mirrorCustomHolds") ?? false;
    containsSpecifiedHolds = _box.get("containsSpecifiedHolds") ?? false;
    onlyFavorites = _box.get("onlyFavorites") ?? false;
    themeName = _box.get("theme");
    List<int> specholds = _box.get("specifiedHolds") ?? [];
    strSpecifiedHolds = specholds.map((e) => JsonService.indexToHoldString(e)).join(", ");
  }

  void refreshFetchedProblems() async {
    var box = Hive.box<Problem>("fetchedProblems");
    setState(() {
      refreshMsg = "fetching...";
    });
    var problemsSqlite = await sqLiteService.problems(grades);
    await box.deleteAll(box.keys);
    await box.putAll(problemsSqlite.asMap());
    setState(() {
      refreshMsg = "Refresh Problems from Database";
    });
  }

  void refreshJsonFileProblems() async {
    setState(() {
      refreshMsgJson = "fetching...";
    });
    var box = Hive.box<Problem>("fetchedJsonProblems");
    await box.deleteAll(box.keys);
    var problemsJson = await JsonService.fetchJsonFile();
    await box.putAll(problemsJson.asMap());
    setState(() {
      refreshMsgJson = "Refresh Problems from Json File";
    });
  }

  void toggleGrade(int e) async {
    setState(() {
      if (grades.contains(e)) {
        grades.remove(e);
      } else {
        grades.add(e);
      }
    });
    _box.put("grades", grades);
  }

  void specifyHolds() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          backgroundColor: _theme.background,
          child: SettingsSpecifyHoldsScreen(),
        );
      },
    ).then((value) {
      setState(() {
        List<int> specholds = _box.get("specifiedHolds") ?? [];
        strSpecifiedHolds = specholds.map((e) => JsonService.indexToHoldString(e)).join(", ");
      });
    });
  }

  void ledTesting() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          backgroundColor: _theme.background,
          child: LedTesterScreen(),
        );
      },
    );
  }

  void specifyCustomBoardHolds() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          backgroundColor: _theme.background,
          child: SettingsSpecifyCustomHoldsScreen(),
        );
      },
    );
  }

  void openHeatmap() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          backgroundColor: _theme.background,
          child: SettingsHeatmapScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomAppBar(title: "Settings"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomCard(
                      headChild: Icon(
                        Icons.dashboard_rounded,
                        color: _theme.foreground,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: showCustomProblems,
                                onChanged: (value) {
                                  setState(() {
                                    showCustomProblems = value;
                                    Hive.box("settings").put("showCustomProblems", showCustomProblems);
                                  });
                                },
                              ),
                              Text(
                                "Custom Problems",
                                style: TextStyle(
                                  color: showCustomProblems ? _theme.accentColor : _theme.foreground,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: showDatabaseProblems,
                                onChanged: (value) {
                                  setState(() {
                                    showDatabaseProblems = value;
                                    Hive.box("settings").put("showDatabaseProblems", showDatabaseProblems);
                                  });
                                },
                              ),
                              Text(
                                "Database Problems",
                                style: TextStyle(
                                  color: showDatabaseProblems ? _theme.accentColor : _theme.foreground,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: showJsonFileProblems,
                                onChanged: (value) {
                                  setState(() {
                                    showJsonFileProblems = value;
                                    Hive.box("settings").put("showJsonFileProblems", showJsonFileProblems);
                                  });
                                },
                              ),
                              Text(
                                "Json File Problems",
                                style: TextStyle(
                                  color: showJsonFileProblems ? _theme.accentColor : _theme.foreground,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: onlyCustomHolds,
                                onChanged: (value) {
                                  setState(() {
                                    onlyCustomHolds = value;
                                    Hive.box("settings").put("onlyCustomHolds", onlyCustomHolds);
                                  });
                                },
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SickButton(
                                      child: Icon(
                                        Icons.edit,
                                        color: _theme.foreground,
                                      ),
                                      onPress: specifyCustomBoardHolds),
                                  Text(
                                    "nur eigene Griffe",
                                    style: TextStyle(
                                      color: onlyCustomHolds ? _theme.accentColor : _theme.foreground,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: mirrorCustomHolds,
                                onChanged: (value) {
                                  setState(() {
                                    mirrorCustomHolds = value;
                                    Hive.box("settings").put("mirrorCustomHolds", mirrorCustomHolds);
                                  });
                                },
                              ),
                              Text(
                                "effirG enegie",
                                style: TextStyle(
                                  color: mirrorCustomHolds ? _theme.accentColor : _theme.foreground,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: onlyFavorites,
                                onChanged: (value) {
                                  setState(() {
                                    onlyFavorites = value;
                                    Hive.box("settings").put("onlyFavorites", onlyFavorites);
                                  });
                                },
                              ),
                              Text(
                                "nur Favoriten",
                                style: TextStyle(
                                  color: onlyFavorites ? _theme.accentColor : _theme.foreground,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: _theme.linksColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                activeColor: _theme.accentColor,
                                value: containsSpecifiedHolds,
                                onChanged: (value) {
                                  setState(() {
                                    containsSpecifiedHolds = value;
                                    Hive.box("settings").put("containsSpecifiedHolds", containsSpecifiedHolds);
                                  });
                                },
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SickButton(
                                      child: Icon(
                                        Icons.edit,
                                        color: _theme.foreground,
                                      ),
                                      onPress: specifyHolds),
                                  Text(
                                    "Problem mit x Griffen",
                                    style: TextStyle(
                                      color: containsSpecifiedHolds ? _theme.accentColor : _theme.foreground,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              strSpecifiedHolds,
                              style: TextStyle(color: _theme.foreground),
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: _theme.linksColor,
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      onPress: openHeatmap,
                      headChild: GradientIcon(
                        Icons.analytics,
                        24,
                        _theme.secondaryLinearGradient,
                      ),
                      child: Text(
                        "Heatmap",
                        style: TextStyle(color: _theme.foreground),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: CustomCard(
                            headChild: showDatabaseProblems
                                ? Icon(
                                    Icons.check_circle,
                                    color: _theme.linksColor,
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Database",
                                  style: TextStyle(
                                    color: _theme.linksColor,
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: _theme.highlight,
                                ),
                                Text(
                                  Utils.fetchProblems(database: true).length.toString(),
                                  style: TextStyle(
                                    color: _theme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomCard(
                            headChild: showJsonFileProblems
                                ? Icon(
                                    Icons.check_circle,
                                    color: _theme.linksColor,
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Json File",
                                  style: TextStyle(
                                    color: _theme.linksColor,
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: _theme.highlight,
                                ),
                                Text(
                                  Utils.fetchProblems(jsonFile: true).length.toString(),
                                  style: TextStyle(
                                    color: _theme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomCard(
                            headChild: showCustomProblems
                                ? Icon(
                                    Icons.check_circle,
                                    color: _theme.linksColor,
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Custom",
                                  style: TextStyle(
                                    color: _theme.linksColor,
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: _theme.highlight,
                                ),
                                Text(
                                  Utils.fetchProblems(custom: true).length.toString(),
                                  style: TextStyle(
                                    color: _theme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomCard(
                      headChild: Icon(
                        Icons.format_list_numbered,
                        color: _theme.foreground,
                      ),
                      padding: 10,
                      child: GridView.count(
                        physics: ScrollPhysics(),
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 5,
                        children: Problem.getAllGradeNumbers()
                            .map(
                              (e) => SickButton(
                                child: Text(
                                  Problem.convertGradeString(e),
                                  style: TextStyle(color: grades.contains(e) ? _theme.accentColor : _theme.foreground),
                                ),
                                onPress: () {
                                  toggleGrade(e);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    CustomCard(
                      headChild: GradientIcon(
                        Icons.color_lens,
                        24,
                        _theme.linearGradient,
                      ),
                      child: Column(
                        children: CustomTheme.themes.map(
                          (e) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Radio(
                                  activeColor: _theme.accentColor,
                                  value: e.themeName,
                                  groupValue: themeName,
                                  onChanged: (String value) async {
                                    themeName = value;
                                    _box.put("theme", themeName);
                                    _theme = e;
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  e.themeName,
                                  style: TextStyle(
                                    color: themeName == e.themeName ? _theme.accentColor : _theme.foreground,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    CustomCard(
                      child: Text(
                        refreshMsg,
                        style: TextStyle(color: _theme.foreground, fontSize: 18),
                      ),
                      onPress: refreshFetchedProblems,
                      headChild: Icon(Icons.refresh, color: _theme.foreground),
                    ),
                    CustomCard(
                      child: Text(
                        refreshMsgJson,
                        style: TextStyle(color: _theme.foreground, fontSize: 18),
                      ),
                      onPress: refreshJsonFileProblems,
                      headChild: Icon(Icons.refresh, color: _theme.foreground),
                    ),
                    CustomCard(
                      headChild: Icon(Icons.update, color: _theme.foreground),
                      child: Text(
                        "Check for Update",
                        style: TextStyle(color: _theme.foreground, fontSize: 18),
                      ),
                      onPress: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: _theme.background,
                              title: Text("Update", style: TextStyle(color: _theme.foreground, fontSize: 18)),
                              content: FutureBuilder<bool>(
                                future: HttpService.updateAvailable(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    String text = snapshot.data ? "Update available" : "No update available";
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            !snapshot.data
                                                ? Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  )
                                                : Icon(
                                                    Icons.warning,
                                                    color: Colors.orange,
                                                  ),
                                            Text(text, style: TextStyle(color: _theme.foreground, fontSize: 18)),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        snapshot.data
                                            ? RaisedButton(
                                                color: _theme.secondBackground,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.download_rounded,
                                                      color: _theme.foreground,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text("Download", style: TextStyle(color: _theme.foreground)),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  const url = "https://xn--blleblle-n4ae.de/install/climbingboard";
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  }
                                                },
                                              )
                                            : SizedBox(),
                                      ],
                                    );
                                  }
                                  return LinearProgressIndicator();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    CustomCard(
                      headChild: Icon(Icons.image, color: _theme.operatorsColor),
                      child: Text(
                        "Get new board Layout",
                        style: TextStyle(color: _theme.foreground, fontSize: 18),
                      ),
                      onPress: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: _theme.background,
                              content: FutureBuilder<String>(
                                future: HttpService.refreshWallImage(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    String text = snapshot.data != "error" ? "Loaded" : "Error loading";
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(text, style: TextStyle(color: _theme.foreground, fontSize: 18)),
                                        SizedBox(height: 20),
                                        snapshot.data != "error"
                                            ? Image.file(
                                                File(snapshot.data),
                                                scale: 0.5,
                                              )
                                            : SizedBox(),
                                      ],
                                    );
                                  }
                                  return LinearProgressIndicator();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    CustomCard(
                      child: Text(
                        "LED - Tester",
                        style: TextStyle(color: _theme.foreground, fontSize: 18),
                      ),
                      onPress: ledTesting,
                      headChild: Icon(Icons.lightbulb, color: _theme.stringsColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
