import 'package:awesome_board/models/problem.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class BoardDisplayer extends StatelessWidget {
  final bool customBoard;
  final List<Hold> holds;
  final CustomPainter painter;
  final void Function(int index) callbackOnCellTap;

  const BoardDisplayer({
    Key key,
    this.customBoard,
    this.holds,
    this.painter,
    this.callbackOnCellTap,
  }) : super(key: key);

  Future<ImageProvider> checkImage() async {
    var dir = await getApplicationDocumentsDirectory();
    var file = io.File(dir.path + "/moon.png");
    if (customBoard) {
      if (await file.exists()) {
        return FileImage(file);
      } else {
        return AssetImage("./assets/images/custom_moonboard.png");
      }
    } else {
      return AssetImage("./assets/images/A_2016-B_2016-OS_2016_highRes.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _DrawCircle extends CustomPainter {
  Paint _paint;

  _DrawCircle(Color color) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2 + 5, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
