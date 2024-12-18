@echo off
amigeconv.exe -f bitplane -d 4 .\shooter_tiles.png shooter_tiles.raw
amigeconv.exe -f palette -p pal4 -c 16 -x -n .\shooter_tiles.png shooter_tiles.pal



