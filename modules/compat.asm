    module Compat
; API methods
ESX_GETSETDRV = #89
ESX_FOPEN = #9A
ESX_FCLOSE = #9B
ESX_FSYNC = #9C
ESX_FREAD = #9D
ESX_FWRITE = #9E

FMODE_CREATE = #0E

iwConfig:
    ld a, (UI.cursor_position) : ld hl, UI.offset : add (hl) : ld d, a : call UI.findRow ;; HL = SSID NAME
    ld de, ssid
.copySSID
    ld a, (hl) : and a : jr z, .copyPass
    ld (de),a
    inc hl, de
    jr .copySSID
.copyPass
    ld hl, UI.selectItem.pass_buffer
    ld de, pass
.loop
    ld a, (hl) : and a : jr z, .store
    ld (de),a
    inc hl, de
    jr .loop
.store
    ld a, 0 : rst #8
    db ESX_GETSETDRV

    ld ix,.filename
    ld hl,.filename
    ld b, FMODE_CREATE
    rst #8 
    db ESX_FOPEN

    push af
    ld ix, ssid : ld bc, 160
    rst #8
    db ESX_FWRITE

    pop af
    push af
    rst #8
    db ESX_FSYNC

    pop af
    rst #8
    db ESX_FCLOSE
    ret

.filename db "/sys/config/iw.cfg", 0


ssid    ds 80
pass    ds 80
    endmodule