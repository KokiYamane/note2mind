import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:note2mind/TreeEdit.dart';

String markdown = '''
# root
- リスト1
  - ネスト リスト1_1
    - ネスト リスト1_1_1
    - ネスト リスト1_1_2
  - ネスト リスト1_2
- リスト2
- リスト3
''';

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
  var _currentIndex = -1;
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

  void loadNoteList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const key = "note-list";

    if (mounted) {
      setState(() => _noteList = prefs.getStringList(key) ?? []);
    }
  }

  void _addNote() {
    setState(() {
      // _noteList.add("");
      _noteList.add(markdown);
      _currentIndex = _noteList.length - 1;
      storeNoteList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new TreeEdit(_noteList[_currentIndex], _onChanged);
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider(height: 2);
          final index = (i / 2).floor();
          final note = _noteList[index];
          return _buildWrappedRow(note, index);
        });
  }

  Widget _buildWrappedRow(String content, int index) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _noteList.removeAt(index);
        });
        storeNoteList();
      },
      child: _buildRow(content, index),
    );
  }

  Widget _buildRow(String content, int index) {
    return LongPressDraggable(
      child: Card(
        child: ListTile(
          title: Text(
            content,
            style: _biggerFont,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            _currentIndex = index;
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return new TreeEdit(_noteList[_currentIndex], _onChanged);
            }));
          },
        )
      ),
      feedback: Card(
        child: Text(
          content,
          style: _biggerFont,
          // maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      )
    );
  }
}
