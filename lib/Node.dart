class Node {
  String title;
  List<Node> children;

  Node({this.title});

  addNode(String title) {
    this.children.add(Node(title: title));
  }
}
