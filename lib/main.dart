import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:note2mind/Edit.dart';
import 'package:note2mind/Node.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Home'),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _noteList = new List<String>();
  var _treeList = new List<Node>();
  var _currentIndex = -1;
  bool _loading = true;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    this.loadNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'add new note',
        child: Icon(Icons.add),
      ),
    );
  }

  void loadNoteList() {
    SharedPreferences.getInstance().then((prefs) {
      const key = "note-list";
      if (prefs.containsKey(key)) {
        _noteList = prefs.getStringList(key);
      }
      setState(() {
        _loading = false;
      });
    });
  }

  void _addNote() {
    setState(() {
      _noteList.add("");
      _currentIndex = _noteList.length - 1;
      storeNoteList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Edit(_noteList[_currentIndex], _onChanged);
        },
      ));
    });
  }

  void _onChanged(String text) {
    setState(() {
      _noteList[_currentIndex] = text;
      storeNoteList();
    });
  }

  void storeNoteList() async {
    final prefs = await SharedPreferences.getInstance();
    const key = "note-list";
    final success = await prefs.setStringList(key, _noteList);
    if (!success) {
      debugPrint("Failed to store value");
    }
  }

  Widget _buildList() {
    final itemCount = _noteList.length == 0 ? 0 : _noteList.length * 2 - 1;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(height: 2);
          final index = (i / 2).floor();
          final note = _noteList[index];
          return _buildWrappedRow(note, index);
        });
  }

  Widget _buildWrappedRow(String content, int index) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(content),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _noteList.removeAt(index);
          storeNoteList();
        });
      },
      child: _buildRow(content, index),
    );
  }

  Widget _buildRow(String content, int index) {
    return ListTile(
      title: Text(
        content,
        style: _biggerFont,
        // maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        _currentIndex = index;
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return new Edit(_noteList[_currentIndex], _onChanged);
        }));
      },
    );
  }
}