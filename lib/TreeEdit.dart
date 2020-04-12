import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/Mindmap.dart';

class TreeEdit extends StatelessWidget {
  final String _current;
  final Function _onChanged;

  TreeEdit(this._current, this._onChanged);

  @override
  Widget build(BuildContext context) {
    final Node root = Node.readMarkdown(_current);

    return Scaffold(
      appBar: _buildAppBar(context, root),
      body: TreeEditField(root: root, onChanged: _onChanged),
      // floatingActionButton: DragTarget<Node>(
      //   builder: (context, candidateData, rejectedData) {
      //     return Container(
      //       width: 50,
      //       height: 50,
      //       color: Colors.grey,
      //       child: Icon(Icons.restore_from_trash),
      //     );
      //     // return ;
      //   },
      //   onAccept: (thisNode) {
      //     thisNode.remove();
      //     _onChanged(root.writeMarkdown());
      //   },
      // ),
    );
  }

  Widget _buildAppBar(BuildContext context, Node root) {
    return AppBar(
      title: TextField(
        controller: TextEditingController(text: root.title),
        focusNode: root.getFocusNode(),
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
        // IconButton(
        //   icon: Icon(Icons.check),
        //   // onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
        //   onPressed: () => root.getFocusNode().requestFocus()
        // ),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.root, this.onChanged}) : super(key: key);

  final Node root;
  final Function onChanged;

  @override
  _TreeEditFieldState createState() => _TreeEditFieldState();
}

class _TreeEditFieldState extends State<TreeEditField> {
  Node currentNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 200), _onTimer);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _createField(widget.root),
    );
  }

  void _onTimer() {
    if (currentNode != null) currentNode.getFocusNode().requestFocus();
  }

  Widget _createField(Node node, [int level = 0]) {
    Widget childrenColumn = Column(
        children: node.children.map<Widget>((Node child) {
      return _createField(child, level + 1);
    }).toList());

    List<Widget> mainWidgetList = new List<Widget>();
    if (level == 0) {
      mainWidgetList.add(childrenColumn);
    } else {
      mainWidgetList.add(_buildWrappedLine(node));
      mainWidgetList.add(Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: childrenColumn));
    }

    return DragTarget<Node>(
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<Node>(
          data: node,
          child: Column(children: mainWidgetList),
          feedback: Card(
              child: Container(
                  height: 50 * node.getNodeNum().toDouble(),
                  width: 300,
                  child: Column(children: mainWidgetList))),
        );
      },
      onAccept: (thisNode) {
        setState(() {
          thisNode.move(node);
        });
        widget.onChanged(widget.root.writeMarkdown());
      },
    );
  }

  Widget _buildWrappedLine(Node node) {
    return Row(children: <Widget>[
      Icon(Icons.arrow_right),
      Expanded(child: _buildLine(node)),
    ]);
  }

  Widget _buildLine(Node node) {
    return TextField(
      controller: TextEditingController(text: node.title),
      focusNode: node.getFocusNode(),
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: (text) {
        node.title = text;
        widget.onChanged(widget.root.writeMarkdown());
      },
      onSubmitted: (text) {
        Node newNode;
        setState(() {
          newNode = node.getParent().insertChild(node, '');
        });
        currentNode = newNode;
        currentNode.getFocusNode().requestFocus();
      },
    );
  }
}
