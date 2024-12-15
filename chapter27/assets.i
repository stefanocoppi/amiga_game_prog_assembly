;****************************************************************
; Assets management
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    IFND       ASSETS_I
ASSETS_I            SET        1

;****************************************************************
; DATA STRUCTURES
;****************************************************************

; graphic or sound asset
                    rsreset
asset.filename      rs.b       24          ; string
asset.dest_address  rs.l       1           ; destination address of asset
asset.length        rs.w       1           ; length in bytes
asset.size          rs.b       0

                    ENDC