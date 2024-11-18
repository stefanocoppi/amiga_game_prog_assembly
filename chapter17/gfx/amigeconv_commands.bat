@echo off
amigeconv.exe -f bitplane -d 8 shooter_tiles.png shooter_tiles.raw
amigeconv.exe -f bitplane -m -d 1 shooter_tiles.png shooter_tiles.mask
amigeconv.exe -f palette -p pal8 -c 256 -x shooter_tiles.png  shooter.pal
amigeconv.exe -f bitplane -d 8 ship.png ship.raw
amigeconv.exe -f bitplane -m -d 1 ship.png ship.mask
amigeconv.exe -f bitplane -d 8 .\ship_engine.png ship_engine.raw
amigeconv.exe -f bitplane -m -d 1 .\ship_engine.png ship_engine.mask
amigeconv.exe -f bitplane -d 8 .\enemies.png enemies.raw
amigeconv.exe -f bitplane -m -d 1 .\enemies.png enemies.mask
amigeconv.exe -f bitplane -d 8 .\ship_shots.png ship_shots.raw
amigeconv.exe -f bitplane -m -d 1 .\ship_shots.png ship_shots.mask
amigeconv.exe -f bitplane -d 8 .\enemy_shots.png enemy_shots.raw
amigeconv.exe -f bitplane -m -d 1 .\enemy_shots.png enemy_shots.mask
amigeconv.exe -f bitplane -d 8 .\enemy_explosion.png enemy_explosion.raw
amigeconv.exe -f bitplane -m -d 1 .\enemy_explosion.png enemy_explosion.mask
amigeconv.exe -f bitplane -d 8 .\ship_explosion.png ship_explosion.raw
amigeconv.exe -f bitplane -m -d 1 .\ship_explosion.png ship_explosion.mask
