import 'dart:convert';
import 'dart:math';

import 'package:awesome_board/models/problem.dart';
import 'package:hive/hive.dart';

class Utils {
  static String convertHoldsToString(List<Hold> holds) {
    List<int> intHolds = [];
    for (var e in holds) {
      var ee = Hold(location: e.location, holdType: e.holdType);
      ee.location = Utils.flipOverY(ee.location, 18 - 1);
      intHolds.add(Utils.convert2DTo1D(ee.location, 11));
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
    bool custom = _box.get("showCustomProblems") ?? false;
    bool database = _box.get("showDatabaseProblems") ?? false;
    bool jsonFile = _box.get("showJsonFileProblems") ?? false;
    return fetchProblems(search: search, custom: custom, database: database, jsonFile: jsonFile);
  }

  static List<Problem> fetchProblems({bool custom = false, bool mirror = false, bool database = false, bool jsonFile = false, String search = ""}) {
    List<Problem> problems = [];
    var box = Hive.box("settings");

    bool onlyCustomHolds = box.get("onlyCustomHolds") ?? false;
    bool mirrorCustomHolds = box.get("mirrorCustomHolds") ?? false;
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
    if (onlyCustomHolds || mirrorCustomHolds) {
      if (onlyCustomHolds && mirrorCustomHolds) {
        problems = problems.where((e) => e.suitedForCustomBoard() || e.mirrorSuitedForCustomBoard()).toList();
      } else {
        if (onlyCustomHolds)
          problems = problems.where((e) => e.suitedForCustomBoard()).toList();
        else
          problems = problems.where((e) => e.mirrorSuitedForCustomBoard()).toList();
      }
    }
    if (containsSpecifiedHolds) {
      problems = problems.where((e) => e.containsHolds(selectedHolds)).toList();
    }

    return problems;
  }

  static Map<int, int> holdHeatMap(List<Problem> problems) {
    Map<int, int> map = Map<int, int>();
    for (var p in problems) {
      for (var i in p.holdIndexesOnly()) {
        if (map.containsKey(i))
          map[i]++;
        else
          map[i] = 1;
      }
    }
    return map;
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
