#!/bin/bash

audioFile=$1

cd ~/Library/Application\ Support/Anki2/User\ 1/collection.media

echo "### B0sh's script: send audio to recent anki card ###"
echo ""

if [ -f "$audioFile" ]; then
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
                    "SentenceAudio": "[sound:'"$audioFile"']"
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
    echo "audio file does not exist"
fi 