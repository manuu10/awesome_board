import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:awesome_board/models/utils.dart';

import 'package:awesome_board/widgets/problem_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
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

  Widget getWidget() {
    return ProblemWidget(
      problem: this,
    );
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
    List<Hold> list = List<Hold>();
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
    return box.get("customHoldIndexes") ?? [];
  }

  static List<int> availableHoldsCustomBoard = [
    189,
    190,
    191,
    192,
    194,
    195,
    185,
    182,
    181,
    179,
    168,
    167,
    166,
    169,
    170,
    171,
    172,
    173,
    163,
    164,
    161,
    160,
    158,
    156,
    145,
    146,
    147,
    149,
    150,
    151,
    140,
    139,
    138,
    137,
    136,
    135,
    133,
    121,
    123,
    124,
    125,
    126,
    127,
    128,
    130,
    129,
    131,
    142,
    119,
    118,
    115,
    114,
    113,
    112,
    110,
    100,
    102,
    103,
    101,
    104,
    105,
    116,
    106,
    107,
    98,
    109,
    108,
    97,
    90,
    91,
    93,
    94,
    95,
    88,
    78,
    79,
    81,
    82,
    83,
    84,
    85,
    86,
    75,
    73,
    71,
    69,
    66,
    67,
    59,
    56,
    68,
    57,
    45,
    46,
    47,
    49,
    61,
    63,
    51,
    53,
    31,
    18,
    39,
    35,
    13,
    15,
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
