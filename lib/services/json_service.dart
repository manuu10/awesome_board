import 'dart:convert';
import 'dart:math';

import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';
import 'package:flutter/services.dart';

class JsonService {
  static Future<List<Problem>> fetchJsonFile() async {
    var content = await parseJsonFromAssets('assets/database/moonboard_problems_setup_2016.json');

    var twoK16 = List<Problem>.from(
      content.keys.map(
        (k) {
          var e = content[k];
          //date in file => Date(8274892374892)
          //filter out every char which isn't a number
          var millDate = int.tryParse(e["DateInserted"].replaceAll(new RegExp(r'[^0-9]'), ''));
          return Problem(
            strId: "json-" + k,
            name: e["Method"] + "~" + e["Name"],
            author: e["Setter"]["Nickname"],
            grade: gradeStringToNumber(e["Grade"]),
            holds: movesToHoldsString(e["Moves"]),
            dateTime: DateTime.fromMillisecondsSinceEpoch(millDate),
          );
        },
      ),
    );
    content = await parseJsonFromAssets('assets/database/moonboard_problems_setup_master2017.json');
    var twoK17 = List<Problem>.from(
      content.keys.map(
        (k) {
          var e = content[k];
          //date in file => Date(8274892374892)
          //filter out every char which isn't a number
          var millDate = int.tryParse(e["DateInserted"].replaceAll(new RegExp(r'[^0-9]'), ''));
          return Problem(
            strId: "json17-" + k,
            name: e["Method"] + "~" + e["Name"],
            author: e["Setter"]["Nickname"],
            grade: gradeStringToNumber(e["Grade"]),
            holds: movesToHoldsString(e["Moves"]),
            dateTime: DateTime.fromMillisecondsSinceEpoch(millDate),
          );
        },
      ),
    );
    twoK16.addAll(twoK17);
    return twoK16;
  }

  static Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle.loadString(assetsPath).then((jsonStr) => jsonDecode(jsonStr));
  }

  static String movesToHoldsString(dynamic moves) {
    List<int> holds = [];
    for (var e in moves) {
      holds.add(holdStringToIndex(e["Description"]));
      if (e["IsStart"] == true)
        holds.add(1);
      else if (e["IsEnd"] == true)
        holds.add(2);
      else
        holds.add(0);
    }
    return json.encode(holds);
  }

  static int holdStringToIndex(String hold) {
    int x = hold.toUpperCase().codeUnitAt(0);
    x = x - 65;
    String sy = hold.substring(1);
    int y = int.parse(sy) - 1;
    return Utils.convert2DTo1D(Point<num>(x, y), 11);
  }

  static String indexToHoldString(int index) {
    var p = Utils.convert1DTo2D(index, 11);
    String letter = String.fromCharCode(65 + p.x);
    return letter + (p.y + 1).toString();
  }

  static int gradeStringToNumber(String grade) {
    switch (grade.toUpperCase()) {
      case "6A":
        return 0;
      case "6A+":
        return 1;
      case "6B":
        return 2;
      case "6B+":
        return 3;
      case "6C":
        return 4;
      case "6C+":
        return 5;
      case "7A":
        return 6;
      case "7A+":
        return 7;
      case "7B":
        return 8;
      case "7B+":
        return 9;
      case "7C":
        return 10;
      case "7C+":
        return 11;
      case "8A":
        return 12;
      case "8A+":
        return 13;
      case "8B":
        return 14;
      case "8B+":
        return 15;
      case "8C":
        return 16;
    }

    return 0;
  }
}
