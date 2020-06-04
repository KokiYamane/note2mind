import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/Mindmap.dart';

class TreeEdit extends StatefulWidget {
  TreeEdit({Key key, this.note, this.onChanged})
      : super(key: key);

  final String note;
  final Function onChanged;

  @override
  _TreeEditState createState() => _TreeEditState();
}

class _TreeEditState extends State<TreeEdit> {
  String note;
  String title;

  @override
  void initState() {
    super.initState();

    note = widget.note;
    title = Node.readMarkdown(note).title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: TreeEditField(
              root: Node.readMarkdown(widget.note),
              onChanged: _saveNote)
        ));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: TextEditingController(text: title),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        onChanged: (text) {
          // Node root = Node.readMarkdown(note);
          // root.title = text;
          title = text;
          // widget.onChanged(root.writeMarkdown());
          // _saveNote(note);
          note = _changeTitle(note, title);
          widget.onChanged(note);
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.image),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return MindmapPage(Node.readMarkdown(note));
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

  String _changeTitle(String markdown, String title) {
    List<String> lines = markdown.split('\n');
    lines[0] = '# ' + title;
    return lines.reduce((curr, next) => curr + '\n' + next);
  }

  void _saveNote(String newNote) {
    setState(() {
      note = newNote;
      note = _changeTitle(note, title);
      widget.onChanged(note);
    });
  }
}

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.root, this.onChanged})
      : super(key: key);

  final Node root;
  final Function onChanged;

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
          _insertNode(newIndex, node);
        },
        children: _lines);
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

  void _insertNode(int index, NodeModel nodeModel) {
    setState(() {
      _tree.insert(index, nodeModel);
      _lines.insert(index, _buildWrappedLine(nodeModel));
    });
    widget.onChanged(makeNote());
  }

  void _removeNode(int index) {
    setState(() {
      _tree.removeAt(index);
      _lines.removeAt(index);
    });
    widget.onChanged(makeNote());
  }

  Widget _buildLine(NodeModel node) {
    return TextField(
      controller: TextEditingController(text: ' ' + node.title),
      textInputAction: TextInputAction.none,
      focusNode: node.focusNode,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: (text) {
        int index = _tree.indexOf(node);
        if (text.isEmpty) {
          if (index == 0) return;
          _tree[index - 1].focusNode.requestFocus();
          _removeNode(index);
        } else
          _tree[index].title = text;
      },
      onEditingComplete: () {
        int index = _tree.indexOf(node) + 1;
        _insertNode(index, NodeModel(title: '', level: node.level));
        _tree[index].focusNode.requestFocus();
      },
    );
  }

  Widget _buildWrappedLine(NodeModel node) {
    return GestureDetector(
        key: UniqueKey(),
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
        onHorizontalDragEnd: (detail) {
          int index = _tree.indexOf(node);
          if (index == 0) return;

          setState(() {
            if (detail.primaryVelocity < 0 && _tree[index].level > 0) {
              _tree[index].level--;
            } else if (0 < detail.primaryVelocity &&
                (_tree[index].level - _tree[index - 1].level) <= 0) {
              _tree[index].level++;
            }
            _lines[index] = _buildWrappedLine(_tree[index]);
          });
          widget.onChanged(makeNote());
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
