;****************************************************************
; Sound management
;
; (c) 2024 Stefano Coppi
;****************************************************************

           incdir     "include/"
           include    "hw.i"
           include    "sound.i"

           xdef       init_sound
           xdef       quit_sound
           xdef       play_sfx
           xdef       stop_sfx
           xdef       play_sample
           xdef       update_sound_engine
          
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

curr_sfx   ds.b       sfx_sizeof                       ; current sound effect
ch_timers  ds.b       sfx_length                       ; channel timers

           SECTION    sounds,CODE

;****************************************************************
; Initialize the sound subsystem.
;****************************************************************
init_sound:
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
           lea        sfx_table,a0
           mulu       #sfx_sizeof,d0                   ; offset = sfx_id * sfx_sizeof
           add.l      d0,a0                            ; pointer to sfx item in the table

; calcola la durata in frame
           move.w     sfx_len(a0),d0                   ; numero di word
           lsl.w      d0                               ; numero di campioni = numero di word * 2
           lsr.w      #3,d0                            ; durata in ms = numero di campioni / 8 campioni/ms
           divu       #20,d0                           ; durata in frames = durata ms / ms/frames

; cerca un canale libero
           lea        ch_timers,a1
           tst.w      sfx_ch0_timer(a1)
           beq        .channel0_free
           tst.w      sfx_ch1_timer(a1)
           beq        .channel1_free
           tst.w      sfx_ch2_timer(a1)
           beq        .channel2_free
           tst.w      sfx_ch3_timer(a1)
           beq        .channel3_free
           bra        .return

.channel0_free:
           move.l     sfx_ptr(a0),AUD0LC(a5)
           move.w     sfx_len(a0),AUD0LEN(a5)
           move.w     sfx_per(a0),AUD0PER(a5)
           move.w     #SFX_VOLUME,AUD0VOL(a5)
           move.w     #%1000000000000001,DMACON(a5)
           move.w     d0,sfx_ch0_timer(a0)             ; inizializza il timer
           bra        .return           

.channel1_free:
           move.l     sfx_ptr(a0),AUD1LC(a5)
           move.w     sfx_len(a0),AUD1LEN(a5)
           move.w     sfx_per(a0),AUD1PER(a5)
           move.w     #SFX_VOLUME,AUD1VOL(a5)
           or.w       #%1000000000000010,DMACON(a5)
           move.w     d0,sfx_ch1_timer(a0)             ; inizializza il timer
           bra        .return

.channel2_free:
           move.l     sfx_ptr(a0),AUD2LC(a5)
           move.w     sfx_len(a0),AUD2LEN(a5)
           move.w     sfx_per(a0),AUD2PER(a5)
           move.w     #SFX_VOLUME,AUD2VOL(a5)
           or.w       #%1000000000000100,DMACON(a5)
           move.w     d0,sfx_ch2_timer(a0)             ; inizializza il timer
           bra        .return
           
.channel3_free:
           move.l     sfx_ptr(a0),AUD3LC(a5)
           move.w     sfx_len(a0),AUD3LEN(a5)
           move.w     sfx_per(a0),AUD3PER(a5)
           move.w     #SFX_VOLUME,AUD3VOL(a5)
           or.w       #%1000000000001000,DMACON(a5)
           move.w     d0,sfx_ch3_timer(a0)             ; inizializza il timer
           bra        .return

.return:
           movem.l    (sp)+,d0-a6
           rts


;****************************************************************
; Updates sound engine state.
;****************************************************************
update_sound_engine:
           movem.l    d0-a6,-(sp)

           lea        ch_timers,a0
; decrementa i timer di ogni canale
           sub.w      #1,sfx_ch0_timer(a0)
           sub.w      #1,sfx_ch1_timer(a0)
           sub.w      #1,sfx_ch2_timer(a0)
           sub.w      #1,sfx_ch3_timer(a0)

           tst.w      sfx_ch0_timer(a0)
           ble        .stop_ch0
           tst.w      sfx_ch1_timer(a0)
           ble        .stop_ch1
           tst.w      sfx_ch2_timer(a0)
           ble        .stop_ch2
           tst.w      sfx_ch3_timer(a0)
           ble        .stop_ch3
           bra        .return

.stop_ch0:
           move.w      #%0000000000000001,DMACON(a5)
           clr.w      sfx_ch0_timer(a0)
           bra        .return

.stop_ch1:
           and.w      #%1111111111111101,DMACON(a5)
           clr.w      sfx_ch1_timer(a0)
           bra        .return

.stop_ch2:
           and.w      #%1111111111111011,DMACON(a5)
           clr.w      sfx_ch2_timer(a0)
           bra        .return

.stop_ch3:
           and.w      #%1111111111110111,DMACON(a5)
           clr.w      sfx_ch3_timer(a0)
           bra        .return

.return:
           movem.l    (sp)+,d0-a6
           rts
