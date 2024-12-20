;****************************************************************
; Takes and releases control of Amiga hardware.
;
; (c) 2024 Stefano Coppi
;****************************************************************

            IFND    TAKEOVER_I
TAKEOVER_I  SET     1



;****************************************************************
; CONSTANTS
;****************************************************************

; DMACON register settings
; enables sprites DMA (bit 5)
; enables only copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
          ; 5432109876543210
DMASET equ %1000001110100000 

            ENDC  

  