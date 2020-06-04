import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:reorderables/reorderables.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/TreeEdit.dart';
import 'package:note2mind/Mindmap.dart';

String markdown = '''
# Central Topic
- subtopic1
  - subtopic1_1
    - related idea1_1_1
    - related idea1_1_2
  - subtopic1_2
    - related idea3_1_1
    - related idea3_1_2
- subtopic2
  - subtopic2_1
    - related idea2_1_1
    - related idea2_1_2
  - subtopic2_2
    - related idea3_1_1
    - related idea3_1_2
- subtopic3
  - subtopic3_1
    - related idea3_1_1
    - related idea3_1_2
  - subtopic3_2
    - related idea3_2_1
    - related idea3_2_2
''';
// String markdown = '''
// # Central Topic
// - subtopic1
// ''';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'note2mind',
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
  List<String> _noteList = List<String>();
  int _currentIndex = -1;

  static const appID = 'ca-app-pub-2711901930280470~3980905909';
  static const adUnitID = 'ca-app-pub-2711901930280470/4689992508';
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    this.loadNoteList();

    FirebaseAdMob.instance.initialize(appId: appID);

    _bannerAd = buildBannerAd();
    _bannerAd
      ..load()
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          // drawer: _buildDrawer(),
          body: _buildGrid(),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNote,
            tooltip: 'add new note',
            child: Icon(Icons.add),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
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
      _noteList.add(markdown);
      _currentIndex = _noteList.length - 1;
      storeNoteList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return TreeEdit(note: _noteList[_currentIndex], onChanged: _onChanged);
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
    return ReorderableWrap(
      padding: const EdgeInsets.all(8),
      onReorder: (int oldIndex, int newIndex) {
        final String note = _noteList.removeAt(oldIndex);
        setState(() {
          _noteList.insert(newIndex, note);
        });
      },
      children: List.generate(_noteList.length, (idx) {
        return _buildWrappedCard(_noteList[idx], idx);
      }),
    );
  }

  Widget _buildCard(Node root, int index) {
    final Size size = MediaQuery.of(context).size;

    return Card(
        child: Container(
            height: size.width / 2 - 16,
            width: size.width / 2 - 16,
            child: Column(children: <Widget>[
              Expanded(
                  child: ListTile(
                title: Text(
                  root.title,
                  maxLines: 2,
                ),
                trailing: _buildPopupMenu(index),
              )),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Mindmap(root: root)),
            ])));
  }

  Widget _buildWrappedCard(String content, int index) {
    Node root = Node.readMarkdown(content);

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        setState(() {
          _noteList.removeAt(index);
        });
        storeNoteList();
      },
      child: GestureDetector(
          onTap: () {
            _currentIndex = index;
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return TreeEdit(note: _noteList[_currentIndex], onChanged: _onChanged);
            }));
          },
          child: _buildCard(root, index)),
    );
  }

  Widget _buildPopupMenu(int index) {
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

  MobileAdTargetingInfo getTargetingInfo() {
    return MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'beautiful apps'],
      contentUrl: 'https://flutter.io',
      childDirected: false,
      testDevices: <String>[], // Android emulators are considered test devices
      // birthday: DateTime.now(),
      // designedForFamilies: false,
      // gender: MobileAdGender.male, // or female, unknown
    );
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      // adUnitId: BannerAd.testAdUnitId,
      adUnitId: adUnitID,
      size: AdSize.fullBanner,
      targetingInfo: getTargetingInfo(),
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }
}
