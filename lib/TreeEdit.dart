import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';

class TreeEdit extends StatelessWidget {
  // String _current;
  Node _current;
  Function _onChanged;

  TreeEdit(this._current, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Edit'),
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
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        // child: new TextField(
        //   controller: TextEditingController(text: _current),
        //   maxLines: 99,
        //   style: new TextStyle(color: Colors.black),
        //   autofocus: true,
        //   onChanged: (text) {
        //     _current = text;
        //     _onChanged(_current);
        //   },
        // )),
        child: TreeEditField(tree: _current),
      ),
    );
  }
}

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.tree}) : super(key: key);

  final Node tree;
  List<Widget> widgetList;

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
    return Column(
      children: <Widget>[Text(widget.tree.title)],
    );
  }

  List<Widget> createWidgetList() {
    List<Widget> widgetList = new List<Widget>();
    widgetList.add(Text(widget.tree.title));
    return widgetList;
  }
}
