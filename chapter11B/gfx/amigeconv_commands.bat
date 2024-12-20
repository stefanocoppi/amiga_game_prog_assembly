@echo off
amigeconv.exe -f bitplane -d 8 .\bgnd_256.png bgnd_256.raw
amigeconv.exe -f palette -p pal8 -c 256 -x .\bgnd_256.png bgnd_256.pal
amigeconv.exe -f sprite -a -w 64 -t -d 4 .\ship.png ship.raw
amigeconv.exe -f palette -p pal8 -c 16 -x .\ship.png ship.pal



