import requests
import json
import sys
import os
import uuid
from subprocess import Popen
from datetime import datetime, timedelta

if sys.platform == 'win32':
    mac = False
    collection_path = os.path.expanduser('~/AppData/Roaming/Anki2/User 1/collection.media')
elif sys.platform == 'darwin':
    mac = True
    collection_path = os.path.expanduser('~/Library/Application Support/Anki2/User 1/collection.media')
    import subprocess

    def asrun(ascript):
        "Run the given AppleScript and return the standard output."

        osa = subprocess.run(['/usr/bin/osascript', '-'], input=ascript, text=True, capture_output=True)
        if osa.returncode == 0:
            return osa.stdout.rstrip()
        else:
            raise ChildProcessError(f'AppleScript: {osa.stderr.rstrip()}')


    def asquote(astr):
        "Return the AppleScript equivalent of the given string."

        astr = astr.replace('"', '" & quote & "')
        return '"{}"'.format(astr)

else:
    raise "Platform not supported"

server = 'http://127.0.0.1:8765'

response = requests.post(server, json = {
    'action': 'getMediaDirPath',
    'version': 6,
})

if response:
    result = json.loads(response.text)
    if result['result'] and os.path.exists(result['result']):
        collection_path = result['result']
        print(result)
    else:
        raise "Media folder not found"
    

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
card_image = ""

if not recent_png_files:
    print(" Take Screenshot ")

    if mac:
        os.chdir(collection_path)
        card_image = f'Screenshot Mac {datetime.now().strftime("%Y-%m-%d %H-%M-%S")}.jpg'
        print(card_image)
        os.system(f'screencapture -tjpg -i "{card_image}"')
    else:
        # regular share x workflow from here
        os.chdir('C:\Program Files\ShareX')
        os.system('ShareX.exe -workflow "Anki Screenshot"')
else:
    # print (" Screenshot exists ")
    # imgsrc = sorted(recent_png_files, key=lambda f: os.path.getmtime(os.path.join(downloads_dir, f)), reverse=True)[0]
    card_image = recent_png_files[0]
    extension = card_image[-3:]
    if extension == 'png' or extension == 'jpg':
        print(f'Found image: {card_image}')

        downloads_file = f'{downloads_dir}/{card_image}'
        if os.path.exists(f'{collection_path}/{card_image}'):
            card_image = f'{card_image[:-4]}-{str(uuid.uuid4())[0:8]}.{extension}'
            print(f'Renamed to {card_image}')
        anki_file = f'{collection_path}/{card_image}'

        os.rename(downloads_file, anki_file)
    else:
        print('No image in downloads')


if card_image and os.path.exists(f'{collection_path}/{card_image}'):
    response = requests.post(server, json = {
        'action': 'guiBrowse',
        'version': 6,
        'params': {
            'query': 'nid:666'
        }
    })
    print("guiBrowse result", response.text)

    updateDto = {
        'action': 'updateNoteFields',
        'version': 6,
        'params': {
            'note': {
                'id': noteId,
                'fields': {
                    'Picture': f'<img src=\"{card_image}\">'
                }
            }
        }
    }

    if mac:
        # Optional code that look at the current open tab only in chrome and updates the 
        # AnkiCard url and document title for my personal records. The purpose is
        # sometimes I look up words that I hear in videos and can't use yomichan to 
        # get the data. (this is super fun)
        activeTab = asrun('''
            tell application "Google Chrome"
                if 0 < (count of windows) then
                    tell front window
                        { title } of active tab
                    end tell
                else
                    "No windows open in Chrome"
                end if
            end tell
        ''')

        activeURL = asrun('''
            tell application "Google Chrome"
                if 0 < (count of windows) then
                    tell front window
                        { URL } of active tab
                    end tell
                else
                    "No windows open in Chrome"
                end if
            end tell
        ''')
        print("Tab Title: ", activeTab)
        print("Tab URL: ", activeURL)
        
        if activeTab != "No windows open in Chrome" and (
            "youtube.com" in activeURL or "twitch.tv" in activeURL
        ):
            updateDto['params']['note']['fields']['URL'] = f'<a href="{activeURL}">{activeURL}</a>'
            updateDto['params']['note']['fields']['DocumentTitle'] = activeTab


    response = requests.post(server, json = updateDto)
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