;****************************************************************
; Multi-directional map scrolling
;
; (c) 2024 Stefano Coppi
;****************************************************************

          incdir     "include/"
          include    "hw.i"
          include    "map.i"


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
          SECTION    graphics_data,DATA_C

map_gfx   incbin     "gfx/map.raw"             ; map playfield


;****************************************************************
; VARIABLES
;****************************************************************
          SECTION    code_section,CODE

camera_x  dc.w       0                         ; camera coordinates
camera_y  dc.w       0



;****************************************************************
; SUBROUTINES
;****************************************************************

;****************************************************************
; Initializes the game map.
;****************************************************************
          xdef       init_map
init_map:
          movem.l    d0-a6,-(sp)

; initializes bitplane pointers to map playfield
          lea        bplpointers,a1            ; bitplane pointers in the copperlist
          move.l     #map_gfx,d0               ; address of playfield
          move.l     #MAP_PLANE_SZ,d1          ; playfield plane size
          move.l     #MAP_BPP,d7               ; bitplanes number
          jsr        init_bplpointers          

; sets our copperlist address into Copper and starts copperlist execution
          move.l     #copperlist,COP1LC(a5)    
          move.w     d0,COPJMP1(a5)       

          movem.l    (sp)+,d0-a6
          rts


;****************************************************************
; Updates map position, based on the camera position.
;****************************************************************
          xdef       update_map
update_map:
          movem.l    d0-a6,-(sp)

          move.l     #map_gfx,d0               ; address of playfield
; calculates offset_x
          move.w     camera_x,d1
          and.l      #$0000ffff,d1             ; clears high word of d1
          divu       #16,d1                    ; offset_x = camera_x / 16 (in words)
          move.l     d1,d2                     ; makes a copy
          and.l      #$0000ffff,d1             ; clears the remainder (upper word)
          lsl        #1,d1                     ; offset_x in bytes
          add.l      d1,d0                     ; adds offset_x to playfield address
; calculates offset_y          
          move.w     camera_y,d1
          mulu       #MAP_ROW_SIZE,d1          ; offset_y = camera_y * MAP_ROW_SIZE
          add.l      d1,d0                     ; adds offset_y to playfield address

; initializes bitplane pointers to map playfield calculated address
          lea        bplpointers,a1            ; bitplane pointers in the copperlist
          move.l     #MAP_PLANE_SZ,d1          ; playfield plane size
          move.l     #MAP_BPP,d7               ; bitplanes number
          jsr        init_bplpointers          

; calculates the scroll value
          swap       d2                        ; remainder of camera_x / 16
          and.w      #$000f,d2                 ; gets only the least significant 4 bits
          move.w     #$f,d4
          sub.w      d2,d4                     ; $f - remainder
          move.w     d4,d3                     ; makes a copy
          lsl.w      #4,d3
          or.w       d4,d3                     ; combines the scroll values for odd and even bitplanes
          move.w     d3,scrollx

          movem.l    (sp)+,d0-a6
          rts


;****************************************************************
; Moves map with joystick.
;****************************************************************
          xdef       move_map_with_joy
move_map_with_joy:
          movem.l    d0-a6,-(sp)

          move.w     JOY1DAT(a5),d0            ; reads joystick port 1
          btst.l     #1,d0                     ; joy right?
          bne        .joy_right
          btst.l     #9,d0                     ; joy left?
          bne        .joy_left
          bra        .check_vertical
.joy_right:
          add.w      #CAMERA_SPEED,camera_x
          bra        .check_vertical
.joy_left:
          sub.w      #CAMERA_SPEED,camera_x    
.check_vertical:
          move.w     d0,d1                     ; makes a copy of d0
          lsr.w      #1,d1
          eor.w      d1,d0
          btst.l     #8,d0                     ; joy up?
          bne        .joy_up
          btst.l     #0,d0                     ; joy down?
          bne        .joy_down
          bra        .return
.joy_up:
          sub.w      #CAMERA_SPEED,camera_y
          bra        .return
.joy_down:
          add.w      #CAMERA_SPEED,camera_y
.return:
          bsr        limits_map_movement
          movem.l    (sp)+,d0-a6
          rts


;****************************************************************
; Limits map movement.
;****************************************************************
limits_map_movement:
          movem.l    d0-a6,-(sp)

          cmp.w      #CAM_MINY,camera_y        ; camera_y < CAM_MINY?
          blt        .limit_miny
          cmp.w      #CAM_MAX_Y,camera_y       ; camera_y > CAM_MAX_Y?
          bgt        .limit_maxy
          bra        .checkx
.limit_miny:
          move.w     #CAM_MINY,camera_y        ; camera_y = CAM_MINY
          bra        .checkx
.limit_maxy:
          move.w     #CAM_MAX_Y,camera_y       ; camera_y = CAM_MAX_Y
          bra        .checkx

.checkx:
          cmp.w      #CAM_MINX,camera_x        ; camera_x < CAM_MINX ?
          blt        .limit_minx
          cmp.w      #CAM_MAXX,camera_x        ; camera_x > CAM_MAXX ?
          bgt        .limit_maxx
          bra        .return

.limit_minx:
          move.w     #CAM_MINX,camera_x        ; camera_x = CAM_MINX
          bra        .return
.limit_maxx:
          move.w     #CAM_MAXX,camera_x        ; camera_x = CAM_MAXX

.return:
          movem.l    (sp)+,d0-a6
          rts