cd /tmp

echo "B0sh JP ocr script"

rm text.png
screencapture -i text.png

# Take picture of Japanese Text and run OCR (to jisho or clipboard)

if [ -f text.png ]; then
    dimensions=$(file text.png | perl -pe 's/.* ([0-9]+) x ([0-9]+), .*/$1 $2/gm')
    width=$(echo $dimensions | cut -f1 -d\ )
    height=$(echo $dimensions | cut -f2 -d\ )

    if (( width > height )); then
        echo "Using jpn - Detected horizontal text"
        /opt/homebrew/bin/tesseract text.png output -l jpn
    else
        echo "Using jpn_vert - Detected vertical text"
        /opt/homebrew/bin/tesseract text.png output -l jpn_vert
    fi

    if [ $1 = "jisho" ]; then
        text=$(cat output.txt | tr -d " ")
        cat output.txt | tr -d " "

        open "https://jisho.org/search/$text"
    else
        cat output.txt | tr -d " " | LANG=en_US.UTF-8 pbcopy
        cat output.txt | tr -d " "
    fi
fi