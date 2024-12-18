@echo off
amigeconv.exe -f bitplane -d 3 .\tile.png tile.raw
amigeconv.exe -f palette -p pal4 -c 8 -x -n .\tile.png tile.pal



