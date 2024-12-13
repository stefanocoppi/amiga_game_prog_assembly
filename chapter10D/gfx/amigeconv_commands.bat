@echo off
amigeconv.exe -f bitplane -d 4 .\map.png map.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\map.png map.pal



