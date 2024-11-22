;****************************************************************
; Takes and releases control of Amiga hardware.
;
; (c) 2024 Stefano Coppi
;****************************************************************

            IFND       TAKEOVER_I
TAKEOVER_I  SET        1



;****************************************************************
; CONSTANTS
;****************************************************************

; DMACON register settings
                 ;5432109876543210
DMASET       equ %1000001000000000   

            ENDC  

  