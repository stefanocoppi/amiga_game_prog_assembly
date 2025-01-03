;****************************************************************
; Takes and releases control of Amiga hardware.
;
; (c) 2024 Stefano Coppi
;****************************************************************

;****************************************************************
; INCLUDES
;****************************************************************
          incdir     "include"
          include    "hw.i"
          include    "funcdef.i"
          include    "exec/exec_lib.i"
          include    "graphics/graphics_lib.i"
          include    "takeover.i"
 

;****************************************************************
; VARIABLES
;****************************************************************
gfx_name  dc.b       "graphics.library",0,0       ; string containing the name of graphics.library
gfx_base  dc.l       0                            ; base address of graphics.library 
old_dma   dc.w       0                            ; saved state of DMACON


;****************************************************************
; ROUTINES
;****************************************************************

;****************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;****************************************************************
          xdef       take_system   
take_system:
          move.l     ExecBase,a6                  ; base address of Exec
          jsr        _LVOForbid(a6)               ; disables O.S. multitasking
          jsr        _LVODisable(a6)              ; disables O.S. interrupts

          lea        gfx_name,a1                  ; OpenLibrary takes 1 parameter: library name in a1
          jsr        _LVOOldOpenLibrary(a6)       ; opens graphics.library
          move.l     d0,gfx_base                  ; saves base address of graphics.library in a variable

          lea        CUSTOM,a5                    ; a5 will always contain CUSTOM chips base address $dff000
          
          move.w     DMACONR(a5),old_dma          ; saves state of DMA channels in a variable
          move.w     #$7fff,DMACON(a5)            ; disables all DMA channels
          move.w     #DMASET,DMACON(a5)           ; sets only dma channels that we will use   

          move.w     #0,FMODE(a5)                 ; sets 16 bit FMODE
          move.w     #$c00,BPLCON3(a5)            ; sets default value                       
          move.w     #$11,BPLCON4(a5)             ; sets default value

          rts


;****************************************************************
; Releases the hardware control to the O.S.
;****************************************************************
          xdef       release_system
release_system:
          or.w       #$8000,old_dma               ; sets bit 15
          move.w     old_dma,DMACON(a5)           ; restores saved DMA state

          move.l     ExecBase,a6                  ; base address of Exec
          jsr        _LVOPermit(a6)               ; enables O.S. multitasking
          jsr        _LVOEnable(a6)               ; enables O.S. interrupts
          move.l     gfx_base,a1                  ; base address of graphics.library in a1
          jsr        _LVOCloseLibrary(a6)         ; closes graphics.library
          rts