# To install manga ocr:
# brew install mecab
# pip3 install manga-ocr
import os
from manga_ocr import MangaOcr

imgsrc = "/tmp/ocr.png"

os.system(f'screencapture -i "{imgsrc}"')

mocr = MangaOcr()
text = mocr(imgsrc)

if text != "":
    os.system(f'open "https://jisho.org/search/{text}"')

os.system(f'rm {imgsrc}')
