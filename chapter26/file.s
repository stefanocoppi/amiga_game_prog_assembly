;****************************************************************
; File loading
;
; (c) 2024 Stefano Coppi
;****************************************************************

             incdir     "include"
             include    "hw.i"
             include    "funcdef.i"
             include    "exec/exec_lib.i"

     
;****************************************************************
; CONSTANTS
;****************************************************************
MODE_OLDFILE equ $3ed
LVOOpen      equ -$1e
LVORead      equ -$2A
LVOClose     equ -$24


;****************************************************************
; VARIABLES
;****************************************************************
             SECTION    code_section,CODE

dos_name     dc.b       "dos.library",0
             even
dos_base     dc.l       0
file_handle  dc.l       0
             even

;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Initializes file module.
;****************************************************************
             xdef       init_file
init_file:
             movem.l    d0-a6,-(sp)

             move.l     ExecBase,a6               ; base address of Exec
             lea        dos_name,a1 
             jsr        _LVOOldOpenLibrary(a6)    ; opens dos.library
             move.l     d0,dos_base               ; saves base address of dos.library in a variable

.return:
             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Quits file module.
;****************************************************************
             xdef       quit_file
quit_file:
             movem.l    d0-a6,-(sp)

             move.l     ExecBase,a6               ; base address of Exec
             move.l     dos_base,a1
             jsr        _LVOCloseLibrary(a6)      ; closes dos.library

.return:
             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Loads a file from disk using AmigaDOS.
;
; parameters:
; d1.l - pointer to filename (specify the entire path)
; d2.l - address of buffer where to load the file content
; d3.l - file length in bytes
;****************************************************************
             xdef       load_file
load_file:
             movem.l    d0-a6,-(sp)

             move.l     d2,d4                     ; makes a copy
             move.l     #MODE_OLDFILE,d2          ; read mode
             move.l     dos_base,a6
             jsr        LVOOpen(a6)               ; opens file
             move.l     d0,file_handle            ; saves file handle
             beq        .return                   ; if handle = 0 there is an error

             move.l     d0,d1
             move.l     d4,d2
             jsr        LVORead(a6)               ; reads the file

             move.l     file_handle,d1
             move.l     dos_base,a6
             jsr        LVOClose(a6)              ; closes the file
.return:
             movem.l    (sp)+,d0-a6
             rts