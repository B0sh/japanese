#!/bin/bash

# python3 must be installed

cd ~/Library/Application\ Support/Anki2/User\ 1/collection.media

echo "### B0sh's script: send screenshot to recent anki card ###"
echo ""


noteID=$(curl -s -d '{
    "action": "findNotes",
    "version": 6,
    "params": {
        "query": "added:1"
    }
}' -H 'Content-Type: application/json' http://127.0.0.1:8765 | python3 -c '
import json,sys
obj=json.load(sys.stdin)
if obj["result"]:
    print (max(obj["result"]))
else:
    print ("None")')

if [ "$noteID" = "None" ]; then
    echo "No new note found"
    exit
fi

echo "Latest Anki Note ID: $noteID"

# YouTube screenshot extension support:
#   If there is a png file downloaded in the last 3 minutes, use that
#   instead of taking a screenshot
recentPngFiles="$(find ~/Downloads/*.png -cmin -3)"
if [ -z "$recentPngFiles" ]; then
    imgsrc="Screenshot Mac $(date +"%Y-%m-%d %H-%M-%S").png"
    echo $imgsrc 
    screencapture -i "$imgsrc"
else 
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

    # Optional code that look at the current open tab only in chrome and updates the 
    # AnkiCard url and document title for my personal records. The purpose is
    # sometimes I look up words that I hear in videos and can't use yomichan to 
    # get the data. (this is super fun)
    titleUpdate=""
    activeTab=$(osascript -e 'tell application "Google Chrome"
        if 0 < (count of windows) then
            tell front window
                {title, URL} of active tab
            end tell
        else
            "No windows open in Chrome"
        end if
    end tell')

    if [ "$activeTab" = "No windows open in Chrome" ]; then
        echo "No windows open in Chrome" 
    else
        tabTitle=$(echo ${activeTab%, *})
        tabURL=$(echo ${activeTab##* })
        echo "Tab title: $tabTitle"
        echo "URL: $tabURL"

        if [[ "$tabURL" =~ "youtube.com" ]] || [[ "$tabURL" =~ "twitch.tv" ]] ; then
            titleUpdate="\"URL\": \"<a href=\\\"$tabURL\\\">$tabURL</a>\", \"DocumentTitle\": \"$tabTitle\", "
        fi
    fi
    # end optional fun stuff
    
    updateNoteFields=$(curl -s -d '{
        "action": "updateNoteFields",
        "version": 6,
        "params": {
            "note": {
                "id": '"$noteID"',
                "fields": {
                    '"$titleUpdate"'
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