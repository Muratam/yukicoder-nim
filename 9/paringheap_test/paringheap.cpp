struct PairingHeap {
  struct Node {
    int key;
    Node *head, *next;
    Node(int key) : key(key), head(0), next(0) {}
  } * r;
  Node *merge(Node *i, Node *j) {
    if (!i || !j) return i ? i : j;
    if (i->key > j->key) swap(i, j);
    j->next = i->head;
    i->head = j;
    return i;
  }
  Node *mergeList(Node *s) {
    Node n(0);
    while (s) {
      Node *a = s, *b = 0;
      s = s->next;
      a->next = 0;
      if (s) {
        b = s;
        s = s->next;
        b->next = 0;
      }
      a = merge(a, b);
      a->next = n.next;
      n.next = a;
    }  // s == 0
    while (n.next) {
      Node *j = n.next;
      n.next = n.next->next;
      s = merge(j, s);
    }
    return s;
  }
  int top() { return r->key; }
  void pop() { r = mergeList(r->head); }
  void push(int key) { r = merge(r, new Node(key)); }
  bool empty() { return !r; }
  PairingHeap() : r(0) {}
};
