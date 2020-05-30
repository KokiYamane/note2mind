import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/Mindmap.dart';

class TreeEdit extends StatelessWidget {
  final String _current;
  final Function _onChanged;
  final Function _onDispose;

  TreeEdit(this._current, this._onChanged, this._onDispose);

  @override
  Widget build(BuildContext context) {
    final Node root = Node.readMarkdown(_current);

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Scaffold(
          appBar: _buildAppBar(context, root),
          body: TreeEditField(
              root: root, onChanged: _onChanged, onDispose: _onDispose),
        ));
  }

  Widget _buildAppBar(BuildContext context, Node root) {
    return AppBar(
      title: TextField(
        controller: TextEditingController(text: root.title),
        // focusNode: root.getFocusNode(),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        onChanged: (text) {
          root.title = text;
          _onChanged(root.writeMarkdown());
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.image),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return MindmapPage(root);
            }));
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

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.root, this.onChanged, this.onDispose})
      : super(key: key);

  final Node root;
  final Function onChanged;
  final Function onDispose;

  @override
  _TreeEditFieldState createState() => _TreeEditFieldState();
}

class _TreeEditFieldState extends State<TreeEditField> {
  List<NodeModel> _tree = List<NodeModel>();
  List<Widget> _lines = List<Widget>();

  @override
  void initState() {
    super.initState();

    _buildLines();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          final NodeModel node = _tree.removeAt(oldIndex);
          _lines.removeAt(oldIndex);
          setState(() {
            _tree.insert(newIndex, node);
            _lines.insert(newIndex, _buildWrappedLine(node));
          });
          widget.onDispose(makeNote());
        },
        // children: List.generate(_tree.length, (index) {
        //   return _buildWrappedLine(_tree[index]);
        // })
        children: _lines);
  }

  @override
  void dispose() {
    super.dispose();

    widget.onDispose(makeNote());
  }

  void _buildData(Node node, [int level = 0]) {
    node.children.forEach((child) {
      _tree.add(NodeModel(level: level, title: child.title));
      _buildData(child, level + 1);
    });
  }

  void _buildLines() {
    _buildData(widget.root);
    _tree.forEach((node) {
      _lines.add(_buildWrappedLine(node));
    });
  }

  String makeNote() {
    String str = '# ' + widget.root.title + '\n';
    _tree.forEach((node) {
      for (int i = 0; i < node.level + 1; i++) {
        if (i == node.level)
          str += '- ';
        else
          str += '  ';
      }
      str += node.title + '\n';
    });
    debugPrint(str);
    return str;
  }

  Widget _buildLine(NodeModel node) {
    return RawKeyboardListener(
        focusNode: node.focusNode,
        onKey: (event) {
          String keyName = event.logicalKey.debugName;
          int keyID = event.logicalKey.keyId;
          // print('Key: ${keyName}, KeyId: ${keyId}');
          print(keyName);
          print(keyID);
          if (keyName == 'Enter') {
            NodeModel newNode = NodeModel(title: '', level: node.level);
            int index = _tree.indexOf(node) + 1;
            setState(() {
              _tree.insert(index, newNode);
              _lines.insert(index, _buildWrappedLine(newNode));
            });
            _tree[index].focusNode.requestFocus();
          }
        },
        child: TextField(
          controller: TextEditingController(text: ' ' + node.title),
          textInputAction: TextInputAction.none,
          // focusNode: node.focusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (text) {
            if (text.isEmpty) {
              int index = _tree.indexOf(node);
              setState(() {
                _tree.remove(node);
                _lines.removeAt(index);
              });
              index = (index != 0) ? index - 1 : 0;
              _tree[index].focusNode.requestFocus();
            } else
              _tree[_tree.indexOf(node)].title = text;
          },
          onSubmitted: (text) {
            NodeModel newNode = NodeModel(title: '', level: node.level);
            int index = _tree.indexOf(node) + 1;
            setState(() {
              _tree.insert(index, newNode);
              _lines.insert(index, _buildWrappedLine(newNode));
            });
            _tree[index].focusNode.requestFocus();
          },
        ));
  }

  Widget _buildWrappedLine(NodeModel node) {
    return Dismissible(
        key: UniqueKey(),
        // child: GestureDetector(
            child: Container(
              height: 30,
              child: Row(children: <Widget>[
                SpaceBox.width(30 * node.level.toDouble()),
                Icon(
                  Icons.arrow_right,
                  color: Colors.grey[300],
                ),
                Expanded(child: _buildLine(node)),
              ]),
            ),
            // onHorizontalDragEnd: (detail) {
            //   int index = _tree.indexOf(node);
            //   if (index == 0) return;

            //   setState(() {
            //     if (detail.primaryVelocity < 0 && _tree[index].level > 0) {
            //       _tree[index].level--;
            //     } else if (0 < detail.primaryVelocity &&
            //         (_tree[index].level - _tree[index - 1].level) != 1) {
            //       _tree[index].level++;
            //     }
            //   });
            //   widget.onDispose(makeNote());
            // }),
        onDismissed: (direction) {
          setState(() {
            _tree.remove(node);
          });
          widget.onDispose(makeNote());
        });
  }
}

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);
  SpaceBox.height([double value = 8]) : super(height: value);
}

class NodeModel {
  String title;
  int level;
  FocusNode focusNode = FocusNode();

  NodeModel({
    this.title,
    this.level,
  });
}
