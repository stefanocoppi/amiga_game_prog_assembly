;****************************************************************
; Enemies
;
; (c) 2024 Stefano Coppi
;*************************************************************

              include    "playfield.i"
              include    "enemies.i"

              xdef       enemies_array


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
              SECTION    graphics_data,DATA_C

enemies_gfx   incbin     "gfx/enemies.raw"
enemies_mask  incbin     "gfx/enemies.mask"


;****************************************************************
; VARIABLES
;****************************************************************
              SECTION    code_section,CODE
         
enemies_array:
enemy1        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       0                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       5                                     ; enemy.energy
              dc.w       192                                   ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       15                                    ; rect.x
              dc.w       13                                    ; rect.y
              dc.w       34                                    ; rect.width
              dc.w       16                                    ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,53     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,53                  
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0                                  
enemy2        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       1                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       200                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       704                                   ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       12                                    ; rect.y
              dc.w       57                                    ; rect.width
              dc.w       20                                    ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,129    ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,129
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0
enemy3        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       3                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       1088                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       -18                                   ; fire_offx
              dc.w       44                                    ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,65     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,328,65
              dc.w       ENEMY_CMD_PAUSE,25
              dc.w       ENEMY_CMD_FIRE
              dc.w       ENEMY_CMD_GOTO,0,65
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-13*2,0
enemy5        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       2                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       1536                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,127    ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,288,127
              dc.w       ENEMY_CMD_PAUSE,25
              dc.w       ENEMY_CMD_GOTO,0,127
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-12*2,0
enemy6        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       3                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       2048                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,29     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,288,29
              dc.w       ENEMY_CMD_PAUSE,25
              dc.w       ENEMY_CMD_GOTO,0,29
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-12*2,0
enemy7        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       1                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       2560                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,97     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,97 
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0
enemy8        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       1                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       2560                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,97     ; enemy.cmd_list
              dc.w       ENEMY_CMD_PAUSE,60
              dc.w       ENEMY_CMD_GOTO,0,97                                      
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy9        dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       2                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       2943                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,69     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,69
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0
enemy10       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       3                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       3455                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,90     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,90
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0
enemy11       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       4                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       4160                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,100    ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,128+180,100
              dc.w       ENEMY_CMD_PAUSE,30
              dc.w       ENEMY_CMD_GOTO,0,100
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-12*2,0
enemy12       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       5                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       5182                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,10     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,128+180,10
              dc.w       ENEMY_CMD_PAUSE,30
              dc.w       ENEMY_CMD_GOTO,0,10
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-12*2,0
enemy13       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       0                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       5760                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,70     ; enemy.cmd_list
              dc.w       ENEMY_CMD_GOTO,0,70
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-7*2,0
enemy14       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       0                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       5760                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,70     ; enemy.cmd_list
              dc.w       ENEMY_CMD_PAUSE,40
              dc.w       ENEMY_CMD_GOTO,0,70                                      
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy15       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       0                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       5760                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,70     ; enemy.cmd_list
              dc.w       ENEMY_CMD_PAUSE,80
              dc.w       ENEMY_CMD_GOTO,0,70                                      
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy16       dc.w       0                                     ; enemy.x
              dc.w       0                                     ; enemy.y
              dc.w       2                                     ; enemy.speed
              dc.w       64                                    ; enemy.width
              dc.w       45                                    ; enemy.height
              dc.w       0                                     ; enemy.ssheet_c
              dc.w       0                                     ; enemy.ssheet_r
              dc.w       384                                   ; enemy.ssheet_w 
              dc.w       45                                    ; enemy.ssheet_h
              dc.l       enemies_gfx                           ; enemy.imgdata
              dc.l       enemies_mask                          ; enemy.mask
              dc.w       0                                     ; enemy.anim_duration
              dc.w       0                                     ; enemy.anim_timer
              dc.w       0                                     ; enemy.num_frames
              dc.w       ENEMY_STATE_INACTIVE                  ; enemy.state
              dc.w       100                                   ; enemy.score
              dc.w       10                                    ; enemy.energy
              dc.w       5760                                  ; enemy.map_position
              dc.w       0                                     ; enemy.tx
              dc.w       0                                     ; enemy.ty
              dc.w       0                                     ; enemy.cmd_pointer
              dc.w       0                                     ; enemy.pause_timer
              dc.w       0                                     ; rect.x
              dc.w       0                                     ; rect.y
              dc.w       0                                     ; rect.width
              dc.w       0                                     ; rect.height
              dc.w       0                                     ; enemy.flash_timer
              dc.w       0                                     ; enemy.hit_timer
              dc.w       $ffff                                 ; enemy.visible
              dc.w       0                                     ; fire_offx
              dc.w       0                                     ; fire_offy
              dc.w       ENEMY_CMD_SETPOS,CLIP_LEFT+320,70     ; enemy.cmd_list
              dc.w       ENEMY_CMD_PAUSE,120
              dc.w       ENEMY_CMD_GOTO,0,70                                      
              dc.w       ENEMY_CMD_END
              dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0