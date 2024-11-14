enemies_array:
enemy1               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       53                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       192                                                      ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,53                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-8,0                                 
enemy2               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       53                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       192                                                      ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,40                                       ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,53                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0 
enemy3               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       53                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       192                                                      ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,80                                       ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,53                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0 
enemy4               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       53                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       192                                                      ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,120                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,53                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0 
enemy5               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       129                                                      ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       1                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       704                                                      ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,129                                     ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-4*2,0
enemy6               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       40                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       3                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       1088                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,288,40                                    ; enemy.cmd_list
                     dc.w       ENEMY_CMD_PAUSE,25
                     dc.w       ENEMY_CMD_GOTO,0,40
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy7               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       127                                                      ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       2                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       1536                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,288,127                                   ; enemy.cmd_list
                     dc.w       ENEMY_CMD_PAUSE,25
                     dc.w       ENEMY_CMD_GOTO,0,127
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy8               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       29                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       3                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       2048                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,288,29                                    ; enemy.cmd_list
                     dc.w       ENEMY_CMD_PAUSE,25
                     dc.w       ENEMY_CMD_GOTO,0,29
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy9               dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       97                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       1                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       2560                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,97                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-4*2,0
enemy10              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       97                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       1                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       2560                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,60                                       ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,97                                      
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0
enemy11              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       69                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       2                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       2943                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,69                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-4*2,0
enemy12              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       90                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       3                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       3455                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,90                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-4*2,0
enemy13              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       100                                                      ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       4                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       4160                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,128+180,100                               ; enemy.cmd_list
                     dc.w       ENEMY_CMD_PAUSE,30
                     dc.w       ENEMY_CMD_GOTO,0,100
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy14              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       10                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       5                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       5182                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,128+180,10                                ; enemy.cmd_list
                     dc.w       ENEMY_CMD_PAUSE,30
                     dc.w       ENEMY_CMD_GOTO,0,10
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-9*2,0
enemy15              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       70                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       5760                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_GOTO,0,70                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-4*2,0
enemy16              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       70                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       5760                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,40                                       ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,70                                      
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0
enemy17              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       70                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       5760                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,80                                       ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,70                                      
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0
enemy18              dc.w       CLIP_WIDTH+320                                           ; enemy.x
                     dc.w       70                                                       ; enemy.y
                     dc.w       2                                                        ; enemy.speed
                     dc.w       128                                                      ; enemy.width
                     dc.w       86                                                       ; enemy.height
                     dc.w       0                                                        ; enemy.ssheet_c
                     dc.w       0                                                        ; enemy.ssheet_r
                     dc.w       768                                                      ; enemy.ssheet_w 
                     dc.w       86                                                       ; enemy.ssheet_h
                     dc.l       enemies                                                  ; enemy.imgdata
                     dc.l       enemies_m                                                ; enemy.mask
                     dc.w       0                                                        ; enemy.anim_duration
                     dc.w       0                                                        ; enemy.anim_timer
                     dc.w       0                                                        ; enemy.num_frames
                     dc.w       ENEMY_STATE_INACTIVE                                     ; enemy.state
                     dc.w       100                                                      ; enemy.score
                     dc.w       10                                                       ; enemy.energy
                     dc.w       5760                                                     ; enemy.map_position
                     dc.w       0                                                        ; enemy.tx
                     dc.w       0                                                        ; enemy.ty
                     dc.w       0                                                        ; enemy.cmd_pointer
                     dc.w       0                                                        ; enemy.pause_timer
                     dc.w       ENEMY_CMD_PAUSE,120                                      ; enemy.cmd_list
                     dc.w       ENEMY_CMD_GOTO,0,70                                      
                     dc.w       ENEMY_CMD_END
                     dcb.b      ENEMY_CMD_LIST_SIZE-6*2,0