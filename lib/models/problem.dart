import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:awesome_board/models/utils.dart';

import 'package:awesome_board/widgets/problem_widget.dart';
import 'package:uuid/uuid.dart';
part 'problem.g.dart';

enum HoldType {
  startHold,
  finishHold,
  normalHold,
}

class Hold {
  Point location;
  HoldType holdType;
  Hold({
    this.holdType,
    this.location,
  });

  @override
  bool operator ==(rhs) {
    return rhs.location == this.location && rhs.holdType == this.holdType;
  }

  @override
  int get hashCode => super.hashCode;
}

@HiveType(typeId: 0)
class Problem {
  int id;

  @HiveField(0)
  String strId;
  @HiveField(1)
  String name;
  @HiveField(2)
  int holdsType;
  @HiveField(3)
  int holdsSetup;
  @HiveField(4)
  String author;
  @HiveField(5)
  int grade;
  @HiveField(6)
  String holds;
  @HiveField(7)
  DateTime dateTime;
  Problem({
    this.strId,
    @required this.name,
    this.holdsType,
    this.holdsSetup,
    @required this.author,
    @required this.grade,
    @required this.holds,
    this.dateTime,
  }) {
    if (this.strId == null) this.strId = Uuid().v4();
    if (this.holdsSetup == null) this.holdsSetup = 1;
    if (this.holdsType == null) this.holdsType = 4;
  }

  bool isLiked() {
    var box = Hive.box("problemsLiked");
    return box.containsKey(this.strId);
  }

  void like() async {
    var box = Hive.box("problemsLiked");
    await box.put(this.strId, true);
  }

  void dislike() async {
    var box = Hive.box("problemsLiked");
    await box.delete(this.strId);
  }

  Widget getWidget(List<Problem> problems) {
    return ProblemWidget(
      problem: this,
      problems: problems,
    );
  }

  List<Hold> mirrorHolds() {
    return getHolds()
        .map(
          (e) => Hold(
            holdType: e.holdType,
            location: Point<int>(10 - e.location.x, e.location.y),
          ),
        )
        .toList();
  }

  String mirrorHoldsIndexes() {
    return Utils.convertHoldsToString(mirrorHolds());
  }

  //Converting the json String for the Holds to a usable List of objects
  List<Hold> getHolds() {
    return convertHoldStringToList(this.holds);
  }

  bool contains(String rhs) {
    if (rhs.isEmpty) return true;
    return name.toLowerCase().contains(rhs.toLowerCase());
  }

  static List<Hold> convertHoldStringToList(String holds) {
    var tagsJson = jsonDecode(holds);
    List<int> lHolds = List.from(tagsJson);
    List<Hold> list = <Hold>[];
    //Pattern is
    //[a,b,c,d,...]
    //where a and c would be the corresponding index for a hold and
    // b and d would be the Type of Hold matching to that index
    // so we need to go through the array in +2 steps.
    for (int i = 0; i < lHolds.length - 1; i += 2) {
      HoldType holdType;
      switch (lHolds[i + 1]) {
        case 0:
          holdType = HoldType.normalHold;
          break;
        case 1:
          holdType = HoldType.startHold;
          break;
        case 2:
          holdType = HoldType.finishHold;
          break;
      }
      //Converting 1D Array to 2D Grid Array

      Point<int> p = Utils.convert1DTo2D(lHolds[i], 11);
      p = Utils.flipOverY(p, 17);
      list.add(Hold(location: p, holdType: holdType));
    }
    return list;
  }

  String getGradeString() {
    return Problem.convertGradeString(this.grade);
  }

  static List<int> getAllGradeNumbers() {
    List<int> grades = [];
    for (int i = 0; i <= 16; i++) {
      grades.add(i);
    }
    return grades;
  }

  static String convertGradeString(int grade) {
    //Converting the numbers to readable Grades
    switch (grade) {
      case 0:
        return "6A";
        break;
      case 1:
        return "6A+";
        break;
      case 2:
        return "6B";
        break;
      case 3:
        return "6B+";
        break;
      case 4:
        return "6C";
        break;
      case 5:
        return "6C+";
        break;
      case 6:
        return "7A";
        break;
      case 7:
        return "7A+";
        break;
      case 8:
        return "7B";
        break;
      case 9:
        return "7B+";
        break;
      case 10:
        return "7C";
        break;
      case 11:
        return "7C+";
        break;
      case 12:
        return "8A";
        break;
      case 13:
        return "8A+";
        break;
      case 14:
        return "8B";
        break;
      case 15:
        return "8B+";
        break;
      case 16:
        return "8C";
        break;
    }

    return "N/A";
  }

  bool suitedForCustomBoard() {
    var availableHolds = getCustomHoldIndexes();
    var tagsJson = jsonDecode(holds);
    List<int> lHolds = List.from(tagsJson);
    for (int i = 0; i < lHolds.length - 1; i += 2) {
      if (!availableHolds.contains(lHolds[i])) return false;
    }
    return true;
  }

  bool mirrorSuitedForCustomBoard() {
    var availableHolds = getCustomHoldIndexes();
    var flipped = mirrorHolds().map((e) => Utils.flipOverY(e.location, 17)).toList();
    List<int> lHolds = flipped.map((e) => Utils.convert2DTo1D(e, 11)).toList();
    for (int i = 0; i < lHolds.length; i++) {
      if (!availableHolds.contains(lHolds[i])) return false;
    }
    return true;
  }

  List<int> holdIndexesOnly() {
    var tagsJson = jsonDecode(holds);
    List<int> lHolds = List.from(tagsJson);
    List<int> retVal = [];
    for (int i = 0; i < lHolds.length - 1; i += 2) {
      retVal.add(lHolds[i]);
    }
    return retVal;
  }

  bool containsHolds(List<int> selectedHolds) {
    var tagsJson = jsonDecode(holds);
    List<int> lHolds = List.from(tagsJson);
    List<int> holdsOnly = [];
    for (int i = 0; i < lHolds.length - 1; i += 2) {
      holdsOnly.add(lHolds[i]);
    }
    for (var e in selectedHolds) {
      if (!holdsOnly.contains(e)) return false;
    }
    return true;
  }

  static List<int> getCustomHoldIndexes() {
    var box = Hive.box("settings");
    if (!box.containsKey("customHoldIndexes")) return availableHoldsCustomBoard;
    return box.get("customHoldIndexes") ?? [];
  }

  static List<int> availableHoldsCustomBoard = [
    148,
    147,
    158,
    146,
    145,
    156,
    167,
    168,
    179,
    189,
    190,
    191,
    193,
    194,
    182,
    195,
    172,
    173,
    171,
    161,
    160,
    170,
    169,
    166,
    133,
    121,
    123,
    135,
    124,
    136,
    125,
    137,
    126,
    127,
    116,
    149,
    150,
    139,
    138,
    151,
    140,
    142,
    163,
    164,
    131,
    130,
    129,
    128,
    117,
    107,
    119,
    118,
    106,
    105,
    104,
    115,
    114,
    103,
    102,
    113,
    112,
    101,
    110,
    88,
    90,
    91,
    79,
    78,
    66,
    67,
    56,
    57,
    68,
    69,
    81,
    82,
    93,
    94,
    83,
    95,
    84,
    85,
    86,
    108,
    97,
    98,
    109,
    75,
    73,
    72,
    61,
    59,
    49,
    47,
    46,
    44,
    34,
    23,
    25,
    39,
    17,
    20,
    51,
    63,
    53
  ];

  static List<int> createRandomHoldList() {
    var rnd = new Random();
    List<int> holds = List<int>();
    Set<int> holdSet = Set<int>();
    int startHolds = 2;
    int normalHolds = 5;
    int finishHolds = 1;
    var startSection = availableHoldsCustomBoard.where((e) => e < (5 * 11)).toList();
    for (int i = 0; i < startHolds; i++) {
      int index = startSection[rnd.nextInt(startSection.length)];
      int tries = 0;
      while (true) {
        tries++;
        if (holdSet.length == 0 || tries > 100) break;
        Point<num> current = Utils.convert1DTo2D(index, 11);
        Point<num> parent = Utils.convert1DTo2D(holdSet.last, 11);
        if (current.distanceTo(parent) < 4 && current.y > parent.y) {
          if (!holdSet.contains(index)) {
            break;
          }
        }
        index = startSection[rnd.nextInt(startSection.length)];
      }
      holdSet.add(index);
      holds.add(index);
      holds.add(1);
    }

    var normalSection = availableHoldsCustomBoard.where((e) => e < (17 * 11) && e >= (5 * 11)).toList();
    for (int i = 0; i < normalHolds; i++) {
      int index = normalSection[rnd.nextInt(normalSection.length)];
      int tries = 0;
      while (true) {
        tries++;
        if (holdSet.length == 0 || tries > 100) break;
        Point<num> current = Utils.convert1DTo2D(index, 11);
        Point<num> parent = Utils.convert1DTo2D(holdSet.last, 11);
        if (current.distanceTo(parent) < 4 && current.y > parent.y) {
          if (!holdSet.contains(index)) {
            break;
          }
        }
        index = normalSection[rnd.nextInt(normalSection.length)];
      }
      holdSet.add(index);
      holds.add(index);
      holds.add(0);
    }
    var finishSection = availableHoldsCustomBoard.where((e) => e < (18 * 11) && e >= (17 * 11)).toList();
    for (int i = 0; i < finishHolds; i++) {
      int index = finishSection[rnd.nextInt(finishSection.length)];
      int tries = 0;
      while (true) {
        tries++;
        if (holdSet.length == 0 || tries > 100) break;
        Point<num> current = Utils.convert1DTo2D(index, 11);
        Point<num> parent = Utils.convert1DTo2D(holdSet.last, 11);
        if (current.distanceTo(parent) < 4 && current.y > parent.y) {
          if (!holdSet.contains(index)) {
            break;
          }
        }
        index = finishSection[rnd.nextInt(finishSection.length)];
      }
      holdSet.add(index);
      holds.add(index);
      holds.add(2);
    }

    return holds.toList();
  }
}
