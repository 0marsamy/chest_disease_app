import urllib.request, json, urllib.error

url = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyAfYXRtlOMiZYuaVJVpQyUN-PkucA6O8fc'

candidates = [
    ('text', {'parts':['Hello there']}),
    ('text', {'text':'Hello there'}),
    ('textContent', {'parts':['Hello there']}),
    ('textContent', {'text':'Hello there'}),
    ('text_input', {'parts':['Hello there']}),
    ('textInput', {'parts':['Hello there']}),
    ('content', {'parts':['Hello there']}),
    ('content', {'text':'Hello there'}),
    ('prompt', {'parts':['Hello there']}),
    ('input', {'parts':['Hello there']}),
    ('message', {'parts':['Hello there']}),
]

for field, inner in candidates:
    body = {'contents': [{field: inner}]}
    data = json.dumps(body).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type':'application/json'})
    try:
        resp = urllib.request.urlopen(req)
        print('SUCCESS', field, inner)
        print(resp.read().decode())
        break
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print('FAIL', field, inner, 'status', e.code, 'msg', err.split('"message":')[1].split('"status"')[0].strip())
