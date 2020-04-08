import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';

class TreeEdit extends StatelessWidget {
  String _current;
  Node _root;
  Function _onChanged;

  TreeEdit(this._current, this._onChanged) {
    _root = new Node.readMarkdown(_current);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_root.title),
        actions: <Widget>[
          FlatButton(
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Icon(Icons.check),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        leading: FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios),
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

    return Column(children: mainWidgetList);
  }

  Widget _buildWrappedLine(Node node) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable(
          data: node,
          child: Row(children: <Widget>[
            Icon(Icons.arrow_right),
            Expanded(child: _buildLine(node)),
          ]),
          feedback: Text(
            node.title,
            style: const TextStyle(fontSize: 16.0),
          ),
        );
      },
      onAccept: (dynamic) {
        print('onAccept');
      },
    );
  }

  Widget _buildLine(Node node) {
    return TextField(
      controller: TextEditingController(text: node.title),
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: (text) {
        if (text == '') {
          node.remove();
          setState(() {});
          return;
        }
        node.title = text;
        widget.onChanged(widget.root.writeMarkdown());
      },
      onSubmitted: (text) {
        node.getParent().insertChild(node, 'title');
        setState(() {});
      },
    );
  }
}
