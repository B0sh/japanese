import requests
import json
import sys
import os
from datetime import datetime, timedelta

if sys.platform == 'win32':
    mac = False
    mediaPath = os.path.expanduser('~/AppData/Roaming/Anki2/User 1/collection.media')
elif sys.platform == 'darwin':
    mac = True
    mediaPath = os.path.expanduser('~/Library/Application Support/Anki2/User 1/collection.media')
else:
    raise "Platform not supported"

server = 'http://127.0.0.1:8765'

response = requests.post(server, json = {
    'action': 'findNotes',
    'version': 6,
    'params': {
        'query': 'added:1'
    }
})

result = json.loads(response.text)
if result['result']:
    noteId = max(result['result'])
else: 
    raise "No latest note found"

print("Latest Anki Note ID:", noteId)


downloads_dir = os.path.expanduser('~/Downloads')
png_files = [f for f in os.listdir(downloads_dir) if f.endswith('.jpg')]
recent_png_files = [f for f in png_files if (datetime.now() - datetime.fromtimestamp(os.path.getctime(os.path.join(downloads_dir, f)))) <= timedelta(minutes=3)]
imgsrc = ""

if not recent_png_files:
    print(" Take Screenshot ")

    if mac:
        imgsrc = f'Screenshot Mac {datetime.now().strftime("%Y-%m-%d %H-%M-%S")}.png'
        print(imgsrc)
        os.system(f'screencapture -i "{imgsrc}"')
    else:
        # regular share x workflow from here
        os.chdir('C:\Program Files\ShareX')
        os.system('ShareX.exe -workflow "Anki Screenshot"')
else:
    # print (" Screenshot exists ")
    # imgsrc = sorted(recent_png_files, key=lambda f: os.path.getmtime(os.path.join(downloads_dir, f)), reverse=True)[0]
    imgsrc = recent_png_files[0]
    extension = imgsrc[-3:]
    if extension == 'png' or extension == 'jpg':
        os.rename(f'{downloads_dir}/{imgsrc}', f'{mediaPath}/{imgsrc}')
        print(f'Found image: {imgsrc}')
    else:
        print('No image in downloads')


if imgsrc:
    response = requests.post(server, json = {
        'action': 'guiBrowse',
        'version': 6,
        'params': {
            'query': 'nid:666'
        }
    })
    print("guiBrowse result", response.text)

    response = requests.post(server, json = {
        'action': 'updateNoteFields',
        'version': 6,
        'params': {
            'note': {
                'id': noteId,
                'fields': {
                    'Picture': f'<img src=\"{imgsrc}\">'
                }
            }
        }
    })
    print("update result", response.text)

    response = requests.post(server, json = {
        'action': 'guiBrowse',
        'version': 6,
        'params': {
            'query': f'nid:{noteId}'
        }
    })
    print("guiBrowse result", response.text)
else:
    print("Image not found, no update was made")