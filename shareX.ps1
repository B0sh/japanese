# Personal modified version of shareX Anki Image command for windows (combine to one line to use in cli) from https://rentry.co/mining#sharex 

-NoProfile -Command "$medianame = \"%input\" | Split-Path -leaf;

Invoke-RestMethod -Uri http://127.0.0.1:8765 -Method Post -ContentType 'application/json; charset=UTF-8' -Body '{\"action\": \"guiBrowse\", \"version\": 6, \"params\": {\"query\":\"nid:1630873192505\"}}';

$data = Invoke-RestMethod -Uri http://127.0.0.1:8765 -Method Post -ContentType 'application/json; charset=UTF-8' -Body '{\"action\": \"findNotes\", \"version\": 6, \"params\": {\"query\":\"added:1\"}}';

$sortedlist = $data.result | Sort-Object -Descending {[Long]$_};

$noteid = $sortedlist[0];

Invoke-RestMethod -Uri http://127.0.0.1:8765 -Method Post -ContentType 'application/json; charset=UTF-8' -Body \"{`\"action`\": `\"updateNoteFields`\", `\"version`\": 6, `\"params`\": {`\"note`\":{`\"id`\":$noteid, `\"fields`\":{`\"Picture`\":`\"<img src=$medianame>`\"}}}}\"; 

Invoke-RestMethod -Uri http://127.0.0.1:8765 -Method Post -ContentType 'application/json; charset=UTF-8' -Body \"{`\"action`\": `\"guiBrowse`\", `\"version`\": 6, `\"params`\": {`\"query`\":`\"nid:$noteid`\"}}\"; "