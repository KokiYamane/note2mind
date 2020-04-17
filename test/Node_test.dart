import 'package:flutter_test/flutter_test.dart';

import 'package:note2mind/Node.dart';

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
  test('node test', () {
    Node root = new Node('root');
    root.addChild('child1');
    root.getChild('child1').addChild('child2');
    root.getChild('child1').addChild('child3');
    root.addChild('child4');
    print(root.writeMarkdown());

    Node root2 = new Node.readMarkdown(markdown);
    print(root2.writeMarkdown());

    print(root2.getNodeNum().toString());
    print(root.getMaxLevel().toString());
    print(root2.getMaxLevel().toString());
  });
}
