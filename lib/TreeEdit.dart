import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/Mindmap.dart';

class TreeEdit extends StatelessWidget {
  String _current;
  Node _root;
  Function _onChanged;

  TreeEdit(this._current, this._onChanged) {
    _root = Node.readMarkdown(_current);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_root.title),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return Mindmap(_root);
              }));
            },
            child: Icon(Icons.image),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Icon(Icons.check),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        leading: FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ),
      body: TreeEditField(root: _root, onChanged: _onChanged),
    );
  }
}

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.root, this.onChanged}) : super(key: key);

  Node root;
  Function onChanged;

  @override
  _TreeEditFieldState createState() => _TreeEditFieldState();
}

class _TreeEditFieldState extends State<TreeEditField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _createField(widget.root),
    );
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

    return Card(child: DragTarget<Node>(
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<Node>(
          data: node,
          child: Column(children: mainWidgetList),
          feedback: Card(
            child: Text(
              node.title,
              style: const TextStyle(fontSize: 24.0),
            ),
            // child: Column(children: mainWidgetList),
            // child: Expanded(child: Column(children: mainWidgetList)),
          ),
        );
      },
      // onWillAccept: (thisNode) {
      //   return true;
      // },
      onAccept: (thisNode) {
        thisNode.move(node);
        widget.onChanged(widget.root.writeMarkdown());
        setState(() {});
      },
    ));
  }

  Widget _buildWrappedLine(Node node) {
    return Card(child: Row(children: <Widget>[
      Icon(Icons.arrow_right),
      Expanded(child: _buildLine(node)),
    ]));
  }

  Widget _buildLine(Node node) {
    return TextField(
      controller: TextEditingController(text: node.title),
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: (text) {
        node.title = text;
        widget.onChanged(widget.root.writeMarkdown());
      },
      onSubmitted: (text) {
        node.getParent().insertChild(node, '');
        setState(() {});
      },
    );
  }
}
