;****************************************************************
; Multi-directional map scrolling
;
; (c) 2024 Stefano Coppi
;****************************************************************

       IFND    MAP_I
MAP_I  SET     1

             
;****************************************************************
; CONSTANTS
;****************************************************************

MAP_BPP         equ 4
VIEWPORT_WIDTH  equ 320
VIEWPORT_HEIGHT equ 256

MAP_WIDTH       equ 640
MAP_HEIGHT      equ 576
MAP_ROW_SIZE    equ MAP_WIDTH/8
MAP_MOD         equ (MAP_WIDTH-VIEWPORT_WIDTH)/8
MAP_PLANE_SZ    equ MAP_ROW_SIZE*MAP_HEIGHT

CAMERA_SPEED    equ 1
CAM_MINY        equ 0
CAM_MAX_Y       equ MAP_HEIGHT-VIEWPORT_HEIGHT
CAM_MINX        equ 0
CAM_MAXX        equ MAP_WIDTH-VIEWPORT_WIDTH

       ENDC  