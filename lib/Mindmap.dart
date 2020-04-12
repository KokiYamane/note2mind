import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'package:note2mind/Node.dart';

class MindmapPage extends StatelessWidget {
  final Node _root;
  final GlobalKey _mindmapKey = GlobalKey();

  MindmapPage(this._root);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: Zoom(
            width: 1000,
            height: 1000,
            initZoom: 0.0,
            child: RepaintBoundary(
              key: _mindmapKey,
              child: Mindmap(root: _root),
            )));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_root.title),
      actions: <Widget>[
        // IconButton(icon: Icon(Icons.save), onPressed: () {}),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () async {
            Uint8List png = await toImage(_mindmapKey);
            await Share.file('mindmap', 'mindmap.png', png, 'image/png',
                text: 'My mindmap.');
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

Future<Uint8List> toImage(GlobalKey globalKey) async {
  RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();

  ui.Image image = await boundary.toImage();
  ByteData pngBytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return pngBytes.buffer.asUint8List();
}

class Mindmap extends StatefulWidget {
  Mindmap({Key key, this.root}) : super(key: key);

  final Node root;

  @override
  _MindmapState createState() => _MindmapState();
}

class _MindmapState extends State<Mindmap> {
  @override
  Widget build(BuildContext context) {
    CustomPaint customPainter = CustomPaint(
      painter: MindmapPainter(widget.root),
      size: Size(1500, 1000),
    );
    return ClipRect(
        child: FittedBox(
            child: SizedBox(
      height: customPainter.size.height,
      width: customPainter.size.width,
      child: customPainter,
    )));
  }
}

class MindmapPainter extends CustomPainter {
  Node _root;
  Canvas _canvas;
  Size _size;
  MindmapPainter(this._root);

  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  Color _backgroundColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;

    final paint = Paint()..color = _backgroundColor;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);

    _nodePainter(_root, Offset(size.width / 2, size.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _nodePainter(Node node, Offset offset,
      [double start = -pi / 2,
      double range = 2 * pi,
      int level = 0,
      Color boxColor = Colors.black]) {
    node.children.asMap().forEach((idx, child) {
      double step = range / node.children.length;
      double startChild = start + step * idx;
      if (level == 0) {
        startChild = start + step * idx - step / 2;
      }

      Offset childOffset = _getOffset(level, start, range, node, idx);
      Color childBoxColor = boxColor;
      if (level == 0) childBoxColor = colors[idx % colors.length];

      _canvas.drawLine(offset, childOffset, Paint());
      _nodePainter(
          child, childOffset, startChild, step, level + 1, childBoxColor);
    });

    double fontSize;
    if (level == 0)
      fontSize = 50.0;
    else if (level < 3)
      fontSize = 30.0 - 5.0 * level;
    else
      fontSize = 15;

    _paintTextBox(node.title, offset, fontSize, boxColor);
  }

  void _paintTextBox(
      String text, Offset offset, double fontSize, Color boxColor) {
    TextStyle textStyle = TextStyle(
        fontFamily: 'Aclonica',
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: Colors.black);
    TextSpan testStyledSpan = TextSpan(text: text, style: textStyle);
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
    Paint paintWhite = Paint()..color = _backgroundColor;

    Paint line = Paint()
      ..color = boxColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _canvas.drawRRect(rrect, paintWhite);
    _canvas.drawRRect(rrect, line);

    textPainter.paint(_canvas, toCenter);
  }

  Offset _getOffset(int level, double start, double range, Node node, int idx) {
    double rx = 150.0 * (level + 1);
    double ry = 100.0 * (level + 1);
    double step = range / node.children.length;
    double theta = start + step / 2 + idx * step;
    if (level == 0) theta = start + idx * step;
    double dx = _size.width / 2 + rx * cos(theta);
    double dy = _size.height / 2 + ry * sin(theta);

    return Offset(dx, dy);
  }
}
