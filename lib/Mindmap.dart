import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zoom_widget/zoom_widget.dart';

import 'package:note2mind/Node.dart';

class Mindmap extends StatelessWidget {
  Node _root;

  Mindmap(this._root);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_root.title),
          actions: <Widget>[
            FlatButton(
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Icon(Icons.save),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
            FlatButton(
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Icon(Icons.share),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
          leading: FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        body: Zoom(
            width: 1200,
            height: 1200,
            initZoom: 0.0,
            child: CustomPaint(
              painter: MindmapPainter(_root),
            )));
  }
}

class MindmapPainter extends CustomPainter {
  Node _root;
  Canvas _canvas;
  Size _size;
  MindmapPainter(this._root);

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    _nodePainter(_root, Offset(size.width / 2, size.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _nodePainter(Node node, Offset offset,
      [double start = -pi / 2, double range = 2 * pi, int level = 0]) {
    node.children.asMap().forEach((idx, child) {
      double rx = 150.0 * (level + 1);
      double ry = 100.0 * (level + 1);
      double step = range / node.children.length;
      double theta = idx * step + start;
      double dx = _size.width / 2 + rx * cos(theta);
      double dy = _size.height / 2 + ry * sin(theta);
      double startChild = start - step / 4 + step * idx;
      _canvas.drawLine(offset, Offset(dx, dy), Paint());
      _nodePainter(child, Offset(dx, dy), startChild, step, level + 1);
    });
    
    TextStyle textStyle = TextStyle(
        fontFamily: 'Aclonica',
        fontSize: 30.0 - 5.0 * level,
        fontWeight: FontWeight.w500,
        color: Colors.black);
    TextSpan testStyledSpan = TextSpan(text: node.title, style: textStyle);
    TextPainter textPainter =
        TextPainter(text: testStyledSpan, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: 200.0);
    Offset toCenter =
        offset - Offset(textPainter.width / 2, textPainter.height / 2);

    double padding = 5.0;
    Size rectSize =
        Size(textPainter.width + 2 * padding, textPainter.height + 2 * padding);
    Rect rect = toCenter - Offset(padding, padding) & rectSize;
    RRect rrect = RRect.fromRectXY(rect, 12.0, 12.0);
    Paint paint = Paint()..color = Colors.white;

    Paint line = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _canvas.drawRRect(rrect, paint);
    _canvas.drawRRect(rrect, line);
    textPainter.paint(_canvas, toCenter);
  }
}
