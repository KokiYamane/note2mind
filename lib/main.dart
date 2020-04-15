import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/TreeEdit.dart';
import 'package:note2mind/Mindmap.dart';

// String markdown = '''
// # root
// - リスト1
//   - ネスト リスト1_1
//     - ネスト リスト1_1_1
//     - ネスト リスト1_1_2
//   - ネスト リスト1_2
// - リスト2
//   - ネスト リスト2_1
//     - ネスト リスト2_1_1
//     - ネスト リスト2_1_2
//   - ネスト リスト2_2
// - リスト3
//   - ネスト リスト3_1
//     - ネスト リスト3_1_1
//     - ネスト リスト3_1_2
//   - ネスト リスト3_2
//     - ネスト リスト3_2_1
//     - ネスト リスト3_2_2
// ''';
String markdown = '''
# title
- category1
''';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  var _noteList = List<String>();
  var _currentIndex = -1;

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
      // drawer: _buildDrawer(),
      body: _buildGrid(),
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
      // _noteList.add('');
      _noteList.add(markdown);
      _currentIndex = _noteList.length - 1;
      storeNoteList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return TreeEdit(_noteList[_currentIndex], _onChanged);
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

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(_noteList.length, (idx) {
        String note = _noteList[idx];
        return _buildWrappedCard(note, idx);
      }),
    );
  }

  Widget _buildWrappedCard(String content, int index) {
    Node root = Node.readMarkdown(content);

    return Dismissible(
      key: UniqueKey(),
      // direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _noteList.removeAt(index);
        });
        storeNoteList();
      },
      child: DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return LongPressDraggable<int>(
              data: index,
              child: GestureDetector(
                  onTap: () {
                    _currentIndex = index;
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                      return TreeEdit(_noteList[_currentIndex], _onChanged);
                    }));
                  },
                  child: _buildCard(root, index)),
              feedback: _buildCard(root, index));
        },
        onAccept: (moveIndex) {
          String movingItem = _noteList[moveIndex];
          setState(() {
            _noteList.removeAt(moveIndex);
            _noteList.insert(index, movingItem);
          });
        },
      ),
    );
  }

  Widget _buildCard(Node root, int index) {
    return Card(
        child: Container(
            height: 150,
            width: 150,
            child: Column(children: <Widget>[
              Expanded(
                  child: ListTile(
                title: Text(
                  root.title,
                  maxLines: 2,
                ),
                trailing: _buildPopuMenu(index),
              )),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Mindmap(root: root)),
            ])));
  }

  Widget _buildPopuMenu(int index) {
    return PopupMenuButton<String>(
      onSelected: (String s) {
        if (s == 'copy') {
          setState(() => _noteList.insert(index, _noteList[index]));
        } else if (s == 'delete') {
          setState(() => _noteList.removeAt(index));
        }
      },
      itemBuilder: (BuildContext context) {
        return ['copy', 'delete'].map((String s) {
          return PopupMenuItem(
            child: Text(s),
            value: s,
          );
        }).toList();
      },
    );
  }

  // Widget _buildDrawer() {
  //   return Drawer(
  //     child: ListView(
  //       children: <Widget>[
  //         UserAccountsDrawerHeader(
  //           accountName: Text('Raja'),
  //           accountEmail: Text('testemail@test.com'),
  //           currentAccountPicture: CircleAvatar(
  //             backgroundImage: NetworkImage('http://i.pravatar.cc/300'),
  //           ),
  //         ),
  //         Text('memu'),
  //       ],
  //     ),
  //   );
  // }
}
