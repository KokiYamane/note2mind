import 'package:flutter/widgets.dart';

class Node {
  String title = '';
  List<Node> children = new List();
  Node _parent;
  FocusNode _focusNode = FocusNode();

  Node(this.title, [this._parent]);

  Node.readMarkdown(String markdown) {
    Node currentNode = this;
    int currentLevel = 0;
    List<String> lines = markdown.split('\n');
    lines.asMap().forEach((index, line) {
      if (index == 0) {
        if (line.startsWith('# ')) title = line.replaceAll('# ', '');
        return;
      }

      for (int start = 0; start < line.length; start += 2) {
        String text = line.substring(start, line.length);
        if (!text.startsWith('- ')) continue;

        int upLevel = currentLevel - start ~/ 2;
        for (int i = 0; i < upLevel; i++) {
          currentNode = currentNode.getParent();
          currentLevel--;
        }

        String childTitle = text.replaceAll('- ', '');
        currentNode = currentNode.addChild(childTitle);
        currentLevel++;
      }
    });
  }

  Node addChild(String title) {
    Node newNode = Node(title, this);
    children.add(newNode);
    return newNode;
  }

  Node insertChild(Node index, String title) {
    Node newNode = Node(title, this);
    children.insert(children.indexOf(index) + 1, newNode);
    return newNode;
  }

  Node getChild(String title) {
    for (int i = 0; i < children.length; i++) {
      String childTitle = children[i].title;
      if (childTitle == title) return children[i];
    }

    return null;
  }

  void removeChild(String title) {
    for (int i = 0; i < children.length; i++) {
      if (children[i].title == title) {
        children.removeAt(i);
        return;
      }
    }
  }

  void remove() {
    _parent.removeChild(title);
  }

  bool isProgeny(Node target) {
    if (target.getParent() == null) return false;
    if (target.getParent() == this) return true;
    return isProgeny(target.getParent());
  }

  void move(Node target) {
    if (target == this) return;
    if (isProgeny(target)) return;

    Node parent = _parent;
    _parent = target;
    target.children.insert(0, this);
    parent.removeChild(title);
  }

  int getNodeNum() {
    if (children.length == 0) return 1;

    int sum = 1;
    for (int i = 0; i < children.length; i++) {
      sum += children[i].getNodeNum();
    }
    return sum;
  }

  Node getParent() => _parent;

  FocusNode getFocusNode() => _focusNode;

  String writeMarkdown([int level = 0]) {
    String str = '';
    if (level == 0)
      str += '# ' + title + '\n';
    else {
      for (int i = 0; i < level; i++) {
        if (i == level - 1)
          str += '- ';
        else
          str += '  ';
      }
      str += title + '\n';
    }
    for (int i = 0; i < children.length; i++) {
      str += children[i].writeMarkdown(level + 1);
    }
    return str;
  }
}
