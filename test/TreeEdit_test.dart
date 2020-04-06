import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/TreeEdit.dart';
import 'package:note2mind/Edit.dart';

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

void main() {
  // Node root;
  // setUp(() {
  //   root = new Node.readMarkdown(markdown);
  // });

  // test('tree edit test', () {
  //   // Navigator.of(context).push(MaterialPageRoute<void>(
  //   //   builder: (BuildContext context) {
  //   //     return new TreeEdit(root);
  //   //   },
  //   // ));
  //   runApp(TreeEdit(root));
  // });

  testWidgets('tree edit test', (WidgetTester tester) async {
    // await tester.pumpWidget(TreeEdit(root));
    await tester.pumpWidget(Edit(markdown, _onChanged));
  });
}

void _onChanged(String text) {
  print('OK');
}
