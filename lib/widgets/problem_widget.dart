import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/screens/problem_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ProblemWidget extends StatefulWidget {
  @override
  _ProblemWidgetState createState() => _ProblemWidgetState();
  final Problem problem;
  final List<Problem> problems;
  const ProblemWidget({
    Key key,
    this.problem,
    this.problems,
  }) : super(key: key);
}

class _ProblemWidgetState extends State<ProblemWidget> {
  CustomTheme theme = CustomTheme.getThemeFromStorage();

  void openProblem() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          backgroundColor: theme.background,
          child: ProblemScreen(
            problem: this.widget.problem,
            problems: this.widget.problems,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Problem problem = this.widget.problem;
    bool liked = problem.isLiked();
    return InkWell(
      onTap: openProblem,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      problem.getGradeString(),
                      style: TextStyle(
                        color: theme.tagsColor,
                      ),
                    ),
                    problem.dateTime != null
                        ? Row(
                            children: [
                              Text(
                                DateFormat("yyyy - MM - dd").format(problem.dateTime),
                                style: TextStyle(
                                  color: theme.attributesColor,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                DateFormat("HH:mm").format(problem.dateTime),
                                style: TextStyle(
                                  color: theme.keywordsColor,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        problem.getSuffixName(),
                        style: TextStyle(
                          color: theme.functionsColor,
                        ),
                      ),
                    ),
                    Text(
                      problem.author,
                      style: TextStyle(
                        color: theme.linksColor,
                      ),
                    ),
                  ],
                ),
                problem.getPrefixMethod() == null
                    ? SizedBox()
                    : Text(
                        problem.getPrefixMethod(),
                        style: TextStyle(
                          color: theme.foreground,
                        ),
                      ),
              ],
            ),
            Positioned.fill(
              child: Align(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    liked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.pink,
                          )
                        : SizedBox(),
                    problem.mirrorSuitedForCustomBoard()
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Colors.yellowAccent,
                            ),
                          )
                        : SizedBox(),
                    problem.suitedForCustomBoard()
                        ? Icon(
                            Icons.check_circle_outline,
                            color: problem.holdsSetup == 999 ? Colors.blueAccent : Colors.green,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
