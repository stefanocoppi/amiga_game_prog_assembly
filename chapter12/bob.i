;************************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;************************************************************************
               IFND       BOB_I
BOB_I          SET        1

               include    "playfield.i"


;****************************************************************
; CONSTANTS
;****************************************************************
BOB_WIDTH    equ 128
BOB_HEIGHT   equ 77
BOB_PLANE_SZ equ BOB_HEIGHT*((BOB_WIDTH+16)/8)


;****************************************************************
; DATA STRUCTURES
;****************************************************************

; bob
               rsreset
bob.valid1     rs.w       1                   ; 1 valid data for buffer 1, 0 invalid
bob.valid2     rs.w       1                   ; 1 valid data for buffer 2, 0 invalid
bob.x          rs.w       1                            
bob.y          rs.w       1
bob.speed      rs.w       1
bob.width      rs.w       1
bob.height     rs.w       1
bob.dst_addr1  rs.l       1                   ; destination address where the background will be restored on dbuffer1
bob.dst_addr2  rs.l       1                   ; destination address where the background will be restored on dbuffer2
bob.bltsize    rs.w       1                   ; blit size
bob.ssheet_c   rs.w       1                   ; spritesheet column of the bob
bob.ssheet_r   rs.w       1                   ; spritesheet row of the bob
bob.ssheet_w   rs.w       1                   ; spritesheet width in pixels
bob.ssheet_h   rs.w       1                   ; spritesheet height in pixels
bob.imgdata    rs.l       1                   ; image data address
bob.mask       rs.l       1                   ; mask address
bob.buffer1    rs.b       BOB_PLANE_SZ*BPP    ; buffer containing the background to be restored on dbuffer1
bob.buffer2    rs.b       BOB_PLANE_SZ*BPP    ; buffer containing the background to be restored on dbuffer2
bob.length     rs.b       0

               ENDC