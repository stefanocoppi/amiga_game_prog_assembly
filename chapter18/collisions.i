;****************************************************************
; Collisions
;
; (c) 2024 Stefano Coppi
;****************************************************************

              IFND       COLLISIONS_I
COLLISIONS_I  SET        1

;****************************************************************
; DATA STRUCTURES
;****************************************************************

; rectangle
              rsreset
rect.x        rs.w       1               ; position of upper left corner
rect.y        rs.w       1
rect.width    rs.w       1               ; width in px
rect.height   rs.w       1               ; height in px
rect.length   rs.b       0

              ENDC