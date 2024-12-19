@echo off
amigeconv.exe -f bitplane -d 4 .\vshooter_tiles.png vshooter_tiles.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\vshooter_tiles.png vshooter_tiles.pal



