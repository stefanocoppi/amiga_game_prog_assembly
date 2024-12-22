;****************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;****************************************************************

                 IFND       BOB_I
BOB_I            SET        1

;****************************************************************
; DATA STRUCTURES
;****************************************************************

; bob
                 rsreset
bob.x            rs.w       1                            
bob.y            rs.w       1
bob.speed        rs.w       1
bob.width        rs.w       1
bob.height       rs.w       1
bob.ssheet_c     rs.w       1        ; spritesheet column of the bob
bob.ssheet_r     rs.w       1        ; spritesheet row of the bob
bob.ssheet_w     rs.w       1        ; spritesheet width in pixels
bob.ssheet_h     rs.w       1        ; spritesheet height in pixels
bob.imgdata      rs.l       1        ; image data address
bob.mask         rs.l       1        ; mask address
bob.length       rs.b       0 

; background of a bob, which needs to be cleared for moving the bob
                 rsreset
bob_bgnd.addr    rs.l       1        ; address in the playfield
bob_bgnd.width   rs.w       1        ; width in pixel
bob_bgnd.height  rs.w       1        ; height in pixel
bob_bgnd.length  rs.b       0

;****************************************************************
; CONSTANTS
;****************************************************************
BGND_LIST_MAX_ITEMS equ 100

                 ENDC