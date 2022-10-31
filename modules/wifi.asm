    MACRO EspSend Text
    ld hl, .txtB
    ld e, (.txtE - .txtB)
    call Wifi.espSend
    jr .txtE
.txtB 
    db Text
.txtE 
    ENDM

    MACRO EspCmd Text
    ld hl, .txtB
    ld e, (.txtE - .txtB)
    call Wifi.espSend
    jr .txtE
.txtB 
    db Text
    db 13, 10 
.txtE
    ENDM

    MACRO EspCmdOkErr text
    EspCmd text
    call Wifi.checkOkErr
    ENDM

    module Wifi
init:
    EspSend "+++"
    ld b, 50
1
    halt
    djnz 1b
    
    call reset

    EspCmdOkErr "ATE0"
    EspCmdOkErr "AT+CWMODE_DEF=1"
    jr c, .err
    EspCmdOkErr "AT+CWAUTOCONN=1"
    jr c, .err
    EspCmdOkErr "AT+CWQAP"
    jr c, .err
    ret
.err
    ld hl, .err_msg
    call Display.putStrLog
    di : halt
.err_msg db 13, "ESP error! Halted!", 0

reset:
    EspCmdOkErr "AT"
    EspCmd "AT+RST"
.loop
    call Uart.read
    cp 'e' : jr nz, .loop
    call Uart.read : cp 'a' : jr nz, .loop
    call Uart.read : cp 'd' : jr nz, .loop
    call Uart.read : cp 'y' : jr nz, .loop
    ret

getList:
    EspCmd "AT+CWLAP"
loadList:
    call Uart.read
    cp '+' : jr z, .plusStart
    cp 'O' : jr z, .okStart
    cp 'E' : jr z, .errStart
    jr loadList
.plusStart
    call Uart.read : cp 'C' : jr nz, loadList
    call Uart.read : cp 'W' : jr nz, loadList
    call Uart.read : cp 'L' : jr nz, loadList
    jr .loadAp
.okStart
    call Uart.read : cp 'K' : jr nz, loadList
    call Uart.read : cp 13  : jr nz, loadList
    ;; Done :-)
    ret
.errStart
    call Uart.read : cp 'R' : jr nz, loadList
    call Uart.read : cp 'R' : jr nz, loadList
    call Uart.read : cp 'O' : jr nz, loadList
    call Uart.read : cp 'R' : jr nz, loadList
    jp init.err
.loadAp
    call Uart.read : cp '"' : jr nz, .loadAp ;; Looking for starting AP name
.loadName
    call Uart.read : cp '"' : jr z, .loadedName
    ld hl, (.buff_ptr) : ld (hl), a : inc hl : ld (.buff_ptr), hl
    jr .loadName
.loadedName
    ld hl, networks_count : inc (hl)
    xor a
    ld hl, (.buff_ptr) : ld (hl), a : inc hl : ld (.buff_ptr), hl
    jr loadList

.buff_ptr dw buffer

networks_count  db 0

; Send buffer to UART
; HL - buff
; E - count
espSend:
    ld a, (hl) 
    push hl, de
    call Uart.write
    pop de, hl
    inc hl 
    dec e
    jr nz, espSend
    ret

espSendZ:
    ld a, (hl) : and a : ret z
    push hl
    call Uart.write
    pop hl
    inc hl
    jr espSendZ

checkOkErr:
    call Uart.read
    cp 'O' : jr z, .okStart ; OK
    cp 'E' : jr z, .errStart ; ERROR
    cp 'F' : jr z, .failStart ; FAIL
    jr checkOkErr
.okStart
    call Uart.read : cp 'K' : jr nz, checkOkErr
    call Uart.read : cp 13  : jr nz, checkOkErr
    call .flushToLF
    or a
    ret
.errStart
    call Uart.read : cp 'R' : jr nz, checkOkErr
    call Uart.read : cp 'R' : jr nz, checkOkErr
    call Uart.read : cp 'O' : jr nz, checkOkErr
    call Uart.read : cp 'R' : jr nz, checkOkErr
    call .flushToLF
    scf 
    ret 
.failStart
    call Uart.read : cp 'A' : jr nz, checkOkErr
    call Uart.read : cp 'I' : jr nz, checkOkErr
    call Uart.read : cp 'L' : jr nz, checkOkErr
    call .flushToLF
    scf
    ret
.flushToLF
    call Uart.read
    cp 10 : jr nz, .flushToLF
    ret

    endmodule