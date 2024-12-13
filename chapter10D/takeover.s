;****************************************************************
; Takes and releases control of Amiga hardware.
;
; (c) 2024 Stefano Coppi
;****************************************************************
          
              incdir     "include"
              include    "hw.i"
              include    "funcdef.i"
              include    "exec/exec_lib.i"
              include    "graphics/graphics_lib.i"
              include    "takeover.i"
 
              xdef       take_system,release_system
              xref       copperlist


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name      dc.b       "graphics.library",0,0        ; string containing the name of graphics.library
gfx_base      dc.l       0                             ; base address of graphics.library
old_dma       dc.w       0                             ; saved state of DMACON
sys_coplist   dc.l       0                             ; address of system copperlist                
old_intena    dc.w       0                             ; saved value of INTENA
old_intreq    dc.w       0                             ; saved value of INTREQ
old_adkcon    dc.w       0                             ; saved value of ADKCON
old_ciaa_icr  dc.b       0 
              even
old_int2      dc.l       0
old_int4      dc.l       0


;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
              move.l     ExecBase,a6                   ; base address of Exec
              jsr        _LVOForbid(a6)                ; disables O.S. multitasking
              jsr        _LVODisable(a6)               ; disables O.S. interrupts

              lea        gfx_name,a1                   ; OpenLibrary takes 1 parameter: library name in a1
              jsr        _LVOOldOpenLibrary(a6)        ; opens graphics.library
              move.l     d0,gfx_base                   ; saves base address of graphics.library in a variable
            
              move.l     d0,a6                         ; gfx base                   
              move.l     $26(a6),sys_coplist           ; saves system copperlist address
             
              jsr        _LVOOwnBlitter(a6)            ; takes the Blitter exclusive

              lea        CUSTOM,a5                     ; a5 will always contain CUSTOM chips base address $dff000
          
              move.w     DMACONR(a5),old_dma           ; saves state of DMA channels in a variable
              move.w     #$7fff,DMACON(a5)             ; disables all DMA channels
              move.w     #DMASET,DMACON(a5)            ; sets only dma channels that we will use

              ; move.l     $68,old_int2
              ; move.l     $70,old_int4

              move.w     INTENAR(a5),old_intena        ; save interrupts state
              move.w     INTREQR(a5),old_intreq
              move.w     ADKCONR(a5),old_adkcon        ; save ADKCON
              ;move.b     CIAAICR,old_ciaa_icr
              move.w     #$7fff,INTENA(a5)             ; disable all interrupts
              move.w     #$7fff,INTREQ(a5)

            ;  move.l     #copperlist,COP1LC(a5)        ; sets our copperlist address into Copper
            ;  move.w     d0,COPJMP1(a5)                ; reset Copper PC to the beginning of our copperlist       

              move.w     #0,FMODE(a5)                  ; sets 16 bit FMODE
              move.w     #$c00,BPLCON3(a5)             ; sets default value                       
              move.w     #$11,BPLCON4(a5)              ; sets default value

              rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
              movem.l    d0-a6,-(sp)

              or.w       #$8000,old_dma                ; sets bit 15
              move.w     old_dma,DMACON(a5)            ; restores saved DMA state
    
              move.w     #$7fff,INTENA(a5)             ; disable all interrupts
              move.w     #$7fff,INTREQ(a5)
              move.w     #$7fff,ADKCON(a5)             ; clears ADKCON
              or.w       #$8000,old_intena             ; sets bit 15
              or.w       #$8000,old_intreq
              or.w       #$8000,old_adkcon
              ;or.w       #%10000000,old_ciaa_icr
              move.w     old_intena,INTENA(a5)         ; restores saved interrupts state
              move.w     old_intreq,INTREQ(a5)
              move.w     old_adkcon,ADKCON(a5)         ; restores old value of ADKCON
              ;move.b     old_ciaa_icr,CIAAICR
             
              ; move.l     old_int2,$68
              ; move.l     old_int4,$70

              move.l     ExecBase,a6                   ; base address of Exec
              jsr        _LVOPermit(a6)                ; enables O.S. multitasking
              jsr        _LVOEnable(a6)                ; enables O.S. interrupts
              move.l     gfx_base,a6
              jsr        _LVODisownBlitter(a6)         ; release Blitter ownership

              move.l     sys_coplist,COP1LC(a5)        ; restores the system copperlist
              move.w     d0,COPJMP1(a5)                ; starts the system copperlist 

              move.l     gfx_base,a1                   ; base address of graphics.library in a1
              jsr        _LVOCloseLibrary(a6)          ; closes graphics.library
              
              movem.l    (sp)+,d0-a6
              rts