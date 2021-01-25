import 'dart:async';
import 'dart:math';

import 'package:awesome_board/models/problem.dart';
import 'package:awesome_board/models/utils.dart';

class PathGenerator {
  final _controller = StreamController<List<Point>>();
  final _ctrlFinish = StreamController<bool>();

  List<List<Point<int>>> alreadyTried = new List<List<Point<int>>>();
  List<Point<int>> current = [];
  Timer _timer;
  Point<int> start = Point<int>(6, 3);
  Point<int> end = Point<int>(5, 17);

  Stream<List<Point>> get stream => _controller.stream;
  Stream<bool> get streamFinished => _ctrlFinish.stream;

  Future<void> dispose() async {
    if (_timer != null) _timer.cancel();
    await _controller.sink.close();
    await _ctrlFinish.sink.close();
  }

  void cancelTimer() {
    if (_timer != null) _timer.cancel();
  }

  Point<int> getRandomStartMaxY(int ceiling) {
    var list = Problem.availableHoldsCustomBoard.map((e) => Utils.convert1DTo2D(e, 11)).toList();
    list.retainWhere((e) => e.y < ceiling);
    list.shuffle();
    return list[0];
  }

  void createRandom({int amount = 7, int distance = 3}) {
    current.clear();
    alreadyTried.clear();

    current.add(getRandomStartMaxY(5));

    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      var cur = current.last;
      if (cur.y == end.y) {
        if (current.length == amount) {
          timer.cancel();
          _controller.sink.add(List<Point<int>>.from(current));
          _ctrlFinish.sink.add(true);
          return;
        } else {
          //reset and try new when top is reached but amount of holds is not satisfied
          resetList();
        }
      }
      _controller.sink.add(List<Point<int>>.from(current));

      var holds = _neighbourHolds(cur, distance);
      holds.shuffle();

      for (var e in holds) {
        //continue if hold is already in current route
        if (current.contains(e)) {
          continue;
        }
        current.add(e);
        if (!Utils.listContainsList(alreadyTried, current)) {
          break;
        } else {
          current.removeLast();
        }
      }

      //reset and try new combination when no next hold could be found;
      if (cur == current.last) {
        resetList();
      }
    });
  }

  void resetList() {
    alreadyTried.add(List<Point<int>>.from(current));
    current.clear();
    current.add(getRandomStartMaxY(5));
  }

  List<Point> _neighbourHolds(Point<int> point, int distance) {
    List<Point<int>> holds = [];

    for (int x = -distance; x <= distance; x++) {
      for (int y = 1; y <= distance; y++) {
        var p = Point<int>(point.x + x, point.y + y);
        if (p.x >= 0 && p.x < 11 && p.y >= 0 && p.y < 18) {
          int indexValue = Utils.convert2DTo1D(p, 11);
          if (Problem.getCustomHoldIndexes().contains(indexValue)) {
            if (!(x == 0 && y == 0)) {
              holds.add(p);
            }
          }
        }
      }
    }
    return holds;
  }
}
