#!/bin/bash
# Dependencies for mac:
# brew install chrome-cli

cd ~/Library/Application\ Support/Anki2/User\ 1/collection.media

echo "### B0sh's script: send screenshot to recent anki card ###"
echo ""

# option for youtube screenshot
if [ "$1" = "downloads" ]; then
    imgsrc="$(ls -t ~/Downloads | head -n1)"
    extension="${imgsrc: -3}"
    if [ "$extension" = "png" ]; then
        # OMG this mv command was so painful. No idea why you can't use ~ in the first argument...
        cd ~/Downloads
        mv "${imgsrc}" ~/Library/Application\ Support/Anki2/User\ 1/collection.media
        cd ~/Library/Application\ Support/Anki2/User\ 1/collection.media
        echo "Found image: $imgsrc"
    else
        echo "No image in downloads"
    fi
else
    imgsrc="Screenshot Mac $(date +"%Y-%m-%d %H-%M-%S").png"
    echo $imgsrc 
    screencapture -i "$imgsrc"
fi

# Add screenshot to last created anki card with AnkiConnect addon

if [ -f "$imgsrc" ]; then
    # Open gui to a random note becaues there's a bug where if the note is
    # already open it won't update the note
    guiBrowse=$(curl -s -d '{
        "action": "guiBrowse",
        "version": 6,
        "params": {
            "query": "\"nid:'1630873192505'\""
        }
    }' -H 'Content-Type: application/json' http://127.0.0.1:8765)

    noteID=$(curl -s -d '{
        "action": "findNotes",
        "version": 6,
        "params": {
            "query": "added:1"
        }
    }' -H 'Content-Type: application/json' http://127.0.0.1:8765 |
    python3 -c 'import json,sys;obj=json.load(sys.stdin);print (max(obj["result"]))')

    echo "Got latest note ID: $noteID"

    
    updateNoteFields=$(curl -s -d '{
        "action": "updateNoteFields",
        "version": 6,
        "params": {
            "note": {
                "id": '"$noteID"',
                "fields": {
                    "Picture": "<img src='"\\\"$imgsrc\\\""'>"
                }
            }
        }
    }' -H 'Content-Type: application/json' http://127.0.0.1:8765)

    echo "updateNoteFields result: $updateNoteFields"

    guiBrowse=$(curl -s -d '{
        "action": "guiBrowse",
        "version": 6,
        "params": {
            "query": "\"nid:'"$noteID"'\""
        }
    }' -H 'Content-Type: application/json' http://127.0.0.1:8765)
    echo "guiBrowse result: $guiBrowse"
else
    echo "image does not exist"
fi