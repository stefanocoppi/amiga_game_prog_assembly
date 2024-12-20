@echo off
amigeconv.exe -f sprite -a -w 16 -t -d 4 .\alien.png alien.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\alien.png alien.pal
amigeconv.exe -f bitplane -d 4 .\bgnd.png bgnd.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\bgnd.png bgnd.pal



