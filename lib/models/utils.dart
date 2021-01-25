import 'dart:math';

import 'package:awesome_board/models/problem.dart';
import 'package:hive/hive.dart';

class Utils {
  static int convert2DTo1D(Point p, int length) {
    return (p.y * length) + p.x;
  }

  static Point<int> convert1DTo2D(int index, int length) {
    int x = (index % length);
    int y = (index ~/ length);

    return Point<int>(x, y);
  }

  static Point<int> flipOverY(Point<int> p, int height) {
    return Point<int>(p.x.toInt(), height - p.y.toInt());
  }

  static List<Problem> fetchProblemUseSettings(String search) {
    var _box = Hive.box("settings");
    bool custom = _box.get("showCustomProblems");
    bool database = _box.get("showDatabaseProblems");
    bool jsonFile = _box.get("showJsonFileProblems");
    if (custom == null) custom = false;
    if (database == null) database = false;
    if (jsonFile == null) jsonFile = false;
    return fetchProblems(search: search, custom: custom, database: database, jsonFile: jsonFile);
  }

  static List<Problem> fetchProblems({bool custom = false, bool database = false, bool jsonFile = false, String search = ""}) {
    List<Problem> problems = [];
    var box = Hive.box("settings");

    bool onlyCustomHolds = box.get("onlyCustomHolds") ?? false;
    bool containsSpecifiedHolds = box.get("containsSpecifiedHolds") ?? false;
    bool onlyFavorites = box.get("onlyFavorites") ?? false;
    List<int> grades = box.get("grades") ?? [];
    List<int> selectedHolds = box.get("specifiedHolds") ?? [];

    if (custom) {
      var box = Hive.box<Problem>("customProblems");
      problems.addAll(box.values.toList());
    }
    if (database) {
      var box = Hive.box<Problem>("fetchedProblems");
      problems.addAll(box.values.toList());
    }
    if (jsonFile) {
      var box = Hive.box<Problem>("fetchedJsonProblems");
      problems.addAll(box.values.toList());
    }
    problems = problems.where((e) => (e.holdsSetup == 1 || e.holdsSetup == 999) && e.holdsType == 4 && e.contains(search)).toList();

    if (onlyFavorites) {
      problems = problems.where((e) => e.isLiked()).toList();
    }
    if (grades.isNotEmpty) {
      problems = problems.where((e) => grades.contains(e.grade)).toList();
    }
    if (onlyCustomHolds) {
      problems = problems.where((e) => e.suitedForCustomBoard()).toList();
    }
    if (containsSpecifiedHolds) {
      problems = problems.where((e) => e.containsHolds(selectedHolds)).toList();
    }

    return problems;
  }

  static bool listContainsList(List<List<Point>> lists, List<Point> list) {
    bool retVal = false;
    lists.forEach((e) {
      bool cmp = list.length == e.length;
      if (cmp) {
        for (int i = 0; i < e.length; i++) {
          if (list[i] != e[i]) cmp = false;
        }
        if (cmp == true) {
          retVal = true;
          return;
        }
      }
    });
    return retVal;
  }
}
