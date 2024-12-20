@echo off
amigeconv.exe -f bitplane -d 8 .\space_bgnd.png .\space_bgnd.raw
amigeconv.exe -f palette -p pal8 -c 256 -x .\space_bgnd.png palette.pal
amigeconv.exe -f bitplane -d 8 .\ship6.png ship6.raw
amigeconv.exe -f bitplane -m -d 1 .\ship6.png ship6.mask




