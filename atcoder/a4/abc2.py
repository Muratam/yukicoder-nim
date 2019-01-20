import re
s = input()
if (re.search("keyence.*", s)
        or re.search("keyenc.*e", s)
        or re.search("keyen.*ce", s)
        or re.search("keye.*nce", s)
        or re.search("key.*ence", s)
        or re.search("ke.*yence", s)
        or re.search("k.*eyence", s)
        or re.search(".*keyence", s)
        ):
    print("YES")
else:
    print("NO")
