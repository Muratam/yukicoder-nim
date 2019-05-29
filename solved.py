import requests
import sys
import http.cookies
from bs4 import BeautifulSoup
import shutil
import os.path
import os


def load_cookies():
    cookies = http.cookies.SimpleCookie()
    with open("cookie", "r") as f:
        cookies.load(f.readline())
    result = {}
    for k, v in cookies.items():
        result[k] = v.value
    return result


def scan_table(soup, verpose=False, ignore_th=False):
    tables = []
    for i_table in soup.select("table"):
        table = []
        for i_tr in i_table.select("tr.solved"):
            tr = []
            for i_td in i_tr.select("td" if ignore_th else "th,td"):
                if verpose:
                    td = {"class": i_td.get("class"), "text": i_td.text}
                else:
                    td = i_td.decode_contents()
                tr.append(td)
            if tr:
                table.append(tr)
        if table:
            tables.append(table)
    return tables[0]


cookies = load_cookies()
for i in range(1, 22):
    url = f"https://yukicoder.me/problems?page={i}"
    html = requests.get(url, cookies=cookies)
    soup = BeautifulSoup(html.text, "html5lib")
    table = scan_table(soup, ignore_th=True)
    for t in table:
        filename = f"y{t[0]}.nim"
        star = str(t[2].count("fa-star"))
        if t[2].count("fa-star-half-full") > 0:
            star = str((int(star) - 1) * 10 + 5)
        if not os.path.exists(filename):
            continue
        dist = "solved/s" + star
        if os.path.exists(dist):
            print("exists!", filename, star)
            dist = "solved/s" + star + "/y" + t[0]
            os.makedirs(dist, exist_ok=True)
        shutil.move(filename, dist)
        print("moved", filename, star)
