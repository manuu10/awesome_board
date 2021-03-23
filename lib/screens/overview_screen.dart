import 'dart:math';

import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:awesome_board/screens/problem_screen.dart';
import 'package:awesome_board/widgets/custom_app_bar.dart';
import 'package:awesome_board/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final CustomTheme _theme = CustomTheme.getThemeFromStorage();

  List<Problem> problems = [];
  Map<DateTime, Problem> history = {};
  bool showHistory = false;
  int problemAmount = 0;
  var txtCtrl = TextEditingController();
  var scrCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshProblems();
  }

  void _refreshProblems() {
    if (!showHistory)
      problems = Utils.fetchProblemUseSettings(txtCtrl.text);
    else {
      var box = Hive.box<Problem>("history");
      history = box.toMap().map((key, value) => MapEntry(DateTime.parse(key.toString()), value));
    }
    setState(() {});
  }

  void openRandomProblem() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          backgroundColor: BlocProvider.of<ThemeBloc>(context).state.background,
          child: ProblemScreen(
            problem: problems[Random().nextInt(problems.length)],
            problems: problems,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, _theme) {
        return Stack(
          children: [
            Container(
              child: Column(
                children: [
                  CustomAppBar(title: "Overview"),
                  CustomCard(
                    headChild: Icon(
                      Icons.search,
                      color: _theme.foreground,
                    ),
                    padding: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (_) => _refreshProblems(),
                              controller: txtCtrl,
                              style: TextStyle(color: _theme.foreground),
                              cursorColor: _theme.accentColor,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: _theme.disabled),
                                hintText: "suche",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: _theme.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _refreshProblems,
                            color: _theme.foreground,
                            icon: Icon(Icons.arrow_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      headChild: Text(
                        problems.length.toString(),
                        style: TextStyle(color: _theme.foreground),
                      ),
                      padding: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Scrollbar(
                          radius: Radius.circular(10),
                          isAlwaysShown: true,
                          controller: scrCtrl,
                          child: Builder(
                            builder: (context) {
                              if (showHistory) {
                                return GroupedListView<MapEntry<DateTime, Problem>, String>(
                                  physics: BouncingScrollPhysics(),
                                  groupBy: (element) => DateFormat("yyyy - MM - dd").format(element.key),
                                  elements: history.entries.toList(),
                                  groupHeaderBuilder: (entry) {
                                    return Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: _theme.highlight,
                                      ),
                                      child: Stack(
                                        children: [
                                          Text(
                                            Utils.dayEnToDeLang(DateFormat("EEEE").format(entry.key)),
                                            style: TextStyle(color: _theme.foreground),
                                          ),
                                          Center(
                                            child: Text(
                                              DateFormat("yyyy - MM - dd").format(entry.key),
                                              style: TextStyle(color: _theme.foreground),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  itemBuilder: (context, entry) {
                                    return entry.value.getWidget(history.values.toList(), fromHistory: true);
                                  },
                                  order: GroupedListOrder.DESC,
                                );
                              }
                              return ListView(
                                controller: scrCtrl,
                                padding: EdgeInsets.only(right: 10),
                                children: problems.map((e) => e.getWidget(problems)).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    elevation: 10,
                    backgroundColor: _theme.highlight,
                    child: Icon(
                      Icons.refresh,
                      color: _theme.linksColor,
                    ),
                    onPressed: _refreshProblems,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    elevation: 10,
                    backgroundColor: showHistory ? _theme.linksColor : _theme.highlight,
                    child: Icon(
                      Icons.history,
                      color: showHistory ? _theme.highlight : _theme.linksColor,
                    ),
                    onPressed: () {
                      showHistory = !showHistory;
                      _refreshProblems();
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    elevation: 10,
                    backgroundColor: _theme.highlight,
                    child: Icon(
                      Icons.shuffle,
                      color: _theme.accentColor,
                    ),
                    onPressed: openRandomProblem,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
