import requests
url = "https://yukicoder.me/problems/28/file"
got = requests.post(url, data={
    "action": "get", "which": "in", "file": "09.txt"
})
print(got.text)
