import urllib.request
import urllib.error
import json

url = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=AIzaSyAfYXRtlOMiZYuaVJVpQyUN-PkucA6O8fc'
body = json.dumps({'model': 'models/gemini-2.5-flash', 'contents': [{'parts': [{'text': 'Hello'}]}]})
req = urllib.request.Request(url, data=body.encode('utf-8'), headers={'Content-Type': 'application/json'})

try:
    resp = urllib.request.urlopen(req)
    print('Status', resp.status)
    print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print('Status', e.code)
    print(e.read().decode('utf-8'))
