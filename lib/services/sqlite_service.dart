import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:awesome_board/models/problem.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  Future<List<Problem>> problems(List<int> grades) async {
    // Construct the path to the app's writable database file:
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "app.db");

    // Delete any existing database:
    await deleteDatabase(dbPath);

// Create the writable database file from the bundled demo database file:
    ByteData data = await rootBundle.load("assets/database/moonboardDB.sqlite");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);

    var db = await openDatabase(dbPath);
    List<Map<String, dynamic>> maps = await db.query(
      'problems',
    );
    if (grades.isNotEmpty) {
      maps = await db.query(
        'problems',
        where: "grade IN (" + grades.join(",") + ")",
      );
    }

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Problem(
        strId: "sqlite-" + maps[i]['id'].toString(),
        name: maps[i]['name'],
        holds: maps[i]['holds'].toString(),
        holdsSetup: maps[i]['holdsSetup'],
        holdsType: maps[i]['holdsType'],
        author: maps[i]['author'],
        grade: maps[i]['grade'],
      );
    });
  }
}
