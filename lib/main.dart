import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ProblemAdapter());
  await Hive.openBox("settings");
  await Hive.openBox("problemsLiked");
  await Hive.openBox<Problem>("customProblems");
  await Hive.openBox<Problem>("fetchedProblems");
  await Hive.openBox<Problem>("fetchedJsonProblems");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AwesomeBoard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
