@echo off
amigeconv.exe -f bitplane -d 4 .\image352.png image352.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\image352.png image352.pal



