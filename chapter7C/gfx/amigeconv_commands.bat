@echo off
amigeconv.exe -f bitplane -d 4 .\image640.png image640.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\image640.png image640.pal



