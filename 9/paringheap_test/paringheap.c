#define NULL 0
#define bool int
typedef struct {
  int key;
  struct Node *head, *next;
} Node;
Node newNode(int key) {
  Node node;
  node.key = key;
  node.head = NULL;
  node.next = NULL;
  return node;
}
typedef struct { Node *r; } ParingHeap;
ParingHeap newParingHeap() {
  ParingHeap ph;
  ph.r = NULL;
  return ph;
}
Node *merge_node(Node *i, Node *j) {
  Node *tmp;
  if (i == NULL || j == NULL) return i == NULL ? i : j;
  if (i->key > j->key) {
    tmp = i;
    i = j;
    j = tmp;
  }
  j->next = i->head;
  i->head = j;
  return i;
}
Node *mergeList(Node *s) {
  Node n = newNode(0);
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
int top(ParingHeap ph) { return ph.r->key; }
void pop(ParingHeap ph) { ph.r = mergeList(ph.r->head); }
void push(ParingHeap ph, int key) { ph.r = merge_node(ph.r, newNode(key)); }
bool empty(ParingHeap ph) { return ph.r != NULL; }

/*
typedef struct PairingHeap {
};
*/