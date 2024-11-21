@echo off
amigeconv.exe -f bitplane -d 4 .\shooter_tiles_16.png shooter_tiles_16.raw
amigeconv.exe -f palette -p pal4 -c 16 -x .\shooter_tiles_16.png shooter_tiles_16.pal
amigeconv.exe -f bitplane -d 4 .\ship.png ship.raw
amigeconv.exe -f bitplane -m -d 1 .\ship.png ship.mask
amigeconv.exe -f palette -p pal4 -c 16 -x .\ship.png pf2_palette.pal
amigeconv.exe -f bitplane -d 4 .\ship_engine.png ship_engine.raw
amigeconv.exe -f bitplane -m -d 1 .\ship_engine.png ship_engine.mask
amigeconv.exe -f bitplane -d 4 .\enemies.png enemies.raw
amigeconv.exe -f bitplane -m -d 1 .\enemies.png enemies.mask
amigeconv.exe -f bitplane -d 4 .\ship_shots.png ship_shots.raw
amigeconv.exe -f bitplane -m -d 1 .\ship_shots.png ship_shots.mask
amigeconv.exe -f bitplane -d 4 .\enemy_shots.png enemy_shots.raw
amigeconv.exe -f bitplane -m -d 1 .\enemy_shots.png enemy_shots.mask