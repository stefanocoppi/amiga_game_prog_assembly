;****************************************************************
; Sound management
;
; (c) 2024 Stefano Coppi
;****************************************************************

             incdir     "include/"
             include    "hw.i"
             include    "sound.i"

             xdef       init_sound_pt
             xdef       quit_sound
             xdef       play_sfx
             xdef       stop_sfx
             xdef       play_sample
             xdef       update_sound_engine
             xdef       init_sound
          
             xref       _mt_install_cia
             xref       _mt_end
             xref       _mt_remove_cia
             xref       _mt_loopfx
             xref       _mt_playfx
             xref       _mt_stopfx
             xref       sfx_table
             xref       _mt_musicmask
             xref       _mt_mastervol


;****************************************************************
; BSS DATA
;****************************************************************
             SECTION    bss_data,BSS_C

curr_sfx     ds.b       sfx_sizeof                       ; current sound effect
ch_counters  ds.b       2*4

             SECTION    sounds,CODE

;****************************************************************
; Initializes the Pro Tracker sound engine.
;****************************************************************
init_sound_pt:
             movem.l    d0/a0/a6,-(sp)

             lea        CUSTOM,a6
             move.l     #0,a0                            ; vectorBase
             moveq      #1,d0                            ; PAL clock
             jsr        _mt_install_cia

             lea        CUSTOM,a6
             move.b     #$01,d0
             jsr        _mt_musicmask

             movem.l    (sp)+,d0/a0/a6
             rts


;****************************************************************
; Quits the sound subsystem.
;****************************************************************
quit_sound:
             movem.l    a6,-(sp)

             lea        CUSTOM,a6
             jsr        _mt_end
             jsr        _mt_remove_cia

             movem.l    (sp)+,a6
             rts


;****************************************************************
; Plays a sound effect.
;
; parameters:
; d0.w - sound effect id
; d1.w - flag 1 loop 0 no loop
;****************************************************************
play_sfx:
             movem.l    d0-d1/a0-a1/a6,-(sp)

             lea        CUSTOM,a6
             lea        curr_sfx,a0

    ; calculates the offset of the sfx_table using the sound effect id
             lea        sfx_table,a1
             mulu       #sfx_sizeof,d0                   ; offset = sfx_id * sfx_sizeof
             add.l      d0,a1                            ; pointer to sfx item in the table

    ; initializes the sfx structure fields using data from the sfx_table
             move.l     sfx_ptr(a1),sfx_ptr(a0)
             move.w     sfx_len(a1),sfx_len(a0)
             move.w     sfx_per(a1),sfx_per(a0)
             move.w     sfx_vol(a1),sfx_vol(a0)
             move.b     sfx_cha(a1),sfx_cha(a0)
             move.b     sfx_pri(a1),sfx_pri(a0)

    ; plays the sound effect
             tst.w      d1
             beq        .no_loop
             jsr        _mt_loopfx
             bra        .return

.no_loop:
             jsr        _mt_playfx
    
.return:
             movem.l    (sp)+,d0-d1/a0-a1/a6
             rts


;****************************************************************
; Stops a sound effect.
; Required only in case of loop.
;
; parameters:
; d0.w - sound effect id
;****************************************************************
stop_sfx:
             movem.l    d0/a0/a6,-(sp)

             lea        CUSTOM,a6
   
    ; calculates the offset of the sfx_table using the sound effect id
             lea        sfx_table,a0
             mulu       #sfx_sizeof,d0                   ; offset = sfx_id * sfx_sizeof
             add.l      d0,a0                            ; pointer to sfx item in the table

             move.b     sfx_cha(a0),d0
             jsr        _mt_stopfx
 
.return:
             movem.l    (sp)+,d0/a0/a6
             rts


;****************************************************************
; Plays a sound effect.
;
; parameters:
; d0.w - sound effect id
;****************************************************************
play_sample:
             movem.l    d0-a6,-(sp)

; calculates the offset of the sfx_table using the sound effect id
             lea        sfx_table,a0                     ; base address of sfx table
             mulu       #sfx_sizeof,d0                   ; offset = sfx_id * sfx_sizeof
             add.l      d0,a0                            ; pointer to sfx item = base address + offset

; finds a free channel
             lea        ch_counters,a1
             tst.w      sfx_ch0_counter(a1)
             beq        .channel0_free
             tst.w      sfx_ch1_counter(a1)
             beq        .channel1_free
             tst.w      sfx_ch2_counter(a1)
             beq        .channel2_free
             tst.w      sfx_ch3_counter(a1)
             beq        .channel3_free
             bra        .return

; plays sound effect
.channel0_free:
             move.l     sfx_ptr(a0),AUD0LC(a5)           ; sets sound registers
             move.w     sfx_len(a0),AUD0LEN(a5)
             move.w     sfx_per(a0),AUD0PER(a5)
             move.w     #SFX_VOLUME,AUD0VOL(a5)
             move.w     #%1000000000000001,DMACON(a5)    ; enables DMA channel
             bra        .return           

.channel1_free:
             move.l     sfx_ptr(a0),AUD1LC(a5)
             move.w     sfx_len(a0),AUD1LEN(a5)
             move.w     sfx_per(a0),AUD1PER(a5)
             move.w     #SFX_VOLUME,AUD1VOL(a5)
             move.w     #%1000000000000010,DMACON(a5)
             bra        .return

.channel2_free:
             move.l     sfx_ptr(a0),AUD2LC(a5)
             move.w     sfx_len(a0),AUD2LEN(a5)
             move.w     sfx_per(a0),AUD2PER(a5)
             move.w     #SFX_VOLUME,AUD2VOL(a5)
             move.w     #%1000000000000100,DMACON(a5)
             bra        .return
           
.channel3_free:
             move.l     sfx_ptr(a0),AUD3LC(a5)
             move.w     sfx_len(a0),AUD3LEN(a5)
             move.w     sfx_per(a0),AUD3PER(a5)
             move.w     #SFX_VOLUME,AUD3VOL(a5)
             move.w     #%1000000000001000,DMACON(a5)
             bra        .return

.return:
             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Updates sound engine state.
;****************************************************************
update_sound_engine:
             movem.l    d0-a6,-(sp)

             lea        ch_counters,a0
             cmp.w      #2,sfx_ch0_counter(a0)
             bge        .stop_ch0
.check_ch1:
             cmp.w      #2,sfx_ch1_counter(a0)
             bge        .stop_ch1
.check_ch2:
             cmp.w      #2,sfx_ch2_counter(a0)
             bge        .stop_ch2
.check_ch3:
             cmp.w      #2,sfx_ch3_counter(a0)
             bge        .stop_ch3
             bra        .return

.stop_ch0:
             move.w     #%0000000000000001,DMACON(a5)
             clr.w      sfx_ch0_counter(a0)
             bra        .check_ch1

.stop_ch1:
             move.w     #%0000000000000010,DMACON(a5)
             clr.w      sfx_ch1_counter(a0)
             bra        .check_ch2

.stop_ch2:
             and.w      #%0000000000000100,DMACON(a5)
             clr.w      sfx_ch2_counter(a0)
             bra        .check_ch3

.stop_ch3:
             and.w      #%0000000000001000,DMACON(a5)
             clr.w      sfx_ch3_counter(a0)
             bra        .return

.return:
             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Initializes the sound subsystem.
;****************************************************************
init_sound:
             movem.l    d0-a6,-(sp)

             move.l     #0,a0
; installs the level 4 interrupt routine
             move.l     #interrupt_lev4,$70(a0)
; enables audio channel interrupts (bits 7-10)
;                         5432109876543210           
             move.w     #%1100011110000000,INTENA(A5)

             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Interrupt handler level 4.
;****************************************************************
interrupt_lev4:
             movem.l    d0-a6,-(sp)
             move.w     INTREQR(a5),d0
             btst.l     #7,d0
             bne        .ch0_read_end
.check_ch1:
             btst.l     #8,d0
             bne        .ch1_read_end
.check_ch2:
             btst.l     #9,d0
             bne        .ch2_read_end
             bra        .clear_irq
.check_ch3:
             btst.l     #10,d0
             bne        .ch3_read_end
             bra        .clear_irq
.ch0_read_end:
             move.w     #1,AUD0LEN(a5)
             lea        ch_counters,a0
             add.w      #1,sfx_ch0_counter(a0)
             bra        .check_ch1
.ch1_read_end:
             move.w     #1,AUD1LEN(a5)
             lea        ch_counters,a0
             add.w      #1,sfx_ch1_counter(a0)
             bra        .check_ch2
.ch2_read_end:
             move.w     #1,AUD2LEN(a5)
             lea        ch_counters,a0
             add.w      #1,sfx_ch2_counter(a0)
             bra        .check_ch3
.ch3_read_end:
             move.w     #1,AUD3LEN(a5)
             lea        ch_counters,a0
             add.w      #1,sfx_ch3_counter(a0)
.clear_irq:
;                         5432109876543210
             move.w     #%0000011110000000,INTREQ(a5)
             movem.l    (sp)+,d0-a6
             rte