# 区間に値を均等に足す・区間の最大値を求める が O(log N)
type StarrySkyTree[T] = ref object
  data:seq[T]
  lazy:seq[T]
  n : int
proc newStarrySkyTree[T](size:int) : StarrySkyTree[T] =
  new(result)
  result.n = size
  result.data = newSeq[T](size)
  result.lazy = newSeq[T](size)
proc add[T](self:StarrySkyTree[T],slice:Slice[int],val:T) =
  discard

proc min[T](self:StarrySkyTree[T],slice:Slice[int]): T =
  discard

#[
struct StarrySky {
static const int MAX_DEPTH = 18;
static const int STsize = 1 << MAX_DEPTH;
Data data[STsize];
Data lazy[STsize]; int n;
StarrySky(void) : n(STsize / 2) {
  REP(i,STsize) data[i] = lazy[i] = 0;
}
void add(int fr, int to, Data val) { upd_sub(fr, to, 2*n-2, 0, n, val); }
Data minimum(int fr, int to) { return min_sub(fr, to, 2*n-2, 0, n); }
private:
  void upd_sub(int fr, int to, int node, int la, int ra, Data val) {
    if (ra<=fr || to<=la) return;
    if (fr<=la && ra<=to) { lazy[node] += val; return; } intleft=(node-n)*2,right=left+1;
    upd_sub(fr, to, left, la, (la+ra)/2, val);
    upd_sub(fr, to, right, (la+ra)/2, ra, val);
    data[node] = min(data[left] + lazy[left], data[right] + lazy[right]);
  }
  Data min_sub(int fr, int to, int node, int la, int ra) {
    if (ra<=fr || to<=la) return 0x7FFFFFFF;
    if (fr<=la && ra<=to) return data[node] + lazy[node];
    Data vl = min_sub(fr, to, (node-n)*2+0, la, (la+ra)/2); 52
    Data vr = min_sub(fr, to, (node-n)*2+1, (la+ra)/2, ra);
    return lazy[node] + min(vl, vr);
  }
};

]#
