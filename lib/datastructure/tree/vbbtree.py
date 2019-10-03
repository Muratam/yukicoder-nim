from math import sqrt
# http://catupper.hatenablog.com/entry/20120830/1346338855


def upsqrt(x):
    res = 1
    while res * res < x:
        res <<= 1
    return res


def botsqrt(x):
    res = 1
    while res * res <= x:
        res <<= 1
    return res >> 1


class Nazoki:
    def __init__(self, universe):
        self.u = 1
        while self.u < universe:
            self.u <<= 1
        self.min = "NIL"
        self.max = "NIL"
        self.summary = "NIL"
        self.cluster = {}

    def high(self, x):
        return x // botsqrt(self.u)

    def low(self, x):
        return x % botsqrt(self.u)

    def index(self, x, y):
        return x * botsqrt(self.u) + y

    def member(self, x):
        if x == self.min or x == self.max:
            return True
        elif self.u == 2:
            return False
        else:
            if self.high(x) in self.cluster:
                return self.cluster[self.high(x)].member(self.low(x))
            else:
                return False

    def empinsert(self, x):
        self.min = self.max = x

    def insert(self, x):
        if self.min == "NIL":
            self.empinsert(x)
            return
        if x < self.min:
            self.min, x = x, self.min
        if self.u > 2:
            if self.high(x) not in self.cluster:
                self.cluster[self.high(x)] = Nazoki(botsqrt(self.u))
                if self.summary == "NIL":
                    self.summary = Nazoki(upsqrt(self.u))
                self.summary.insert(self.high(x))
                self.cluster[self.high(x)].empinsert(self.low(x))
            else:
                self.cluster[self.high(x)].insert(self.low(x))
        if x > self.max:
            self.max = x

    def delete(self, x):
        if self.min == self.max:
            self.min = self.max = "NIL"
            return True
        elif self.u == 2:
            if x == 0:
                self.min = 1
            else:
                self.min = 0
            self.max = self.min
            return False
        else:
            if x == self.min:
                fc = self.summary.min
                x = self.index(fc, self.cluster[fc].min)
                self.min = x
            k = self.cluster[self.high(x)].delete(self.low(x))
            if k:
                del self.cluster[self.high(x)]
                kk = self.summary.delete(self.high(x))
                if x == self.max:
                    if kk:
                        self.max = self.min
                    else:
                        sm = self.summary.max
                        self.max = self.index(sm, self.cluster[sm].max)
            elif x == self.max:
                self.max = self.index(
                    self.high(x), self.cluster[self.high(x)].max)

    def successor(self, x):
        if self.u == 2:
            if x == 0 and self.max == 1:
                return 1
            else:
                return "NIL"
        elif self.min != "NIL" and x < self.min:
            return self.min
        else:
            ml = "NIL"
            if self.high(x) in self.cluster:
                ml = self.cluster[self.high(x)].max
            if ml != "NIL" and self.low(x) < ml:
                offset = self.cluster[self.high(x)].successor(self.low(x))
                return self.index(self.high(x), offset)
            else:
                sc = "NIL"
                sc = self.summary.successor(self.high(x))
                if sc == "NIL":
                    return "NIL"
                else:
                    offset = self.cluster[sc].min
                    return self.index(sc, offset)

    def predecessor(self, x):
        if self.u == 2:
            if x == 1 and self.min == 0:
                return 0
            else:
                return "NIL"
        elif self.max != "NIL" and x > self.max:
            return self.max
        else:
            ml = "NIL"
            if self.high(x) in self.cluster:
                ml = self.cluster[self.high(x)].min
            if ml != "NIL" and self.low(x) > ml:
                offset = self.cluster[self.high(x)].predecessor(self.low(x))
                return self.index(self.high(x), offset)
            else:
                pc = "NIL"
                if self.summary != "NIL":
                    pc = self.summary.predecessor(self.high(x))
                if pc == "NIL":
                    if self.min != "NIL" and x > self.min:
                        return self.min
                    else:
                        return "NIL"
                else:
                    offset = self.cluster[pc].max
                    return self.index(pc, offset)


if __name__ == "__main__":
    x = Nazoki(64)
    for i in range(10, 20):
        x.insert(i)
    # x.delete(15)
    # x.delete(18)
    # x.delete(10)
    for i in range(30):
        if x.member(i):
            print(i)
