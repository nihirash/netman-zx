    module UI
PER_PAGE = 14

init:
    call Display.clrscr
    setLineColor 0, 117o : gotoXY 0, 0 : printMsg msg_head
    setLineColor 15, 017o : gotoXY 0, 15 : printMsg msg_log
    ret

topClean:
    call Display.clrTop
    gotoXY 0, 15 : printMsg msg_log
    gotoXY 0, 0 : printMsg msg_head
    ret

renderList:
    call topClean

    ld a, (offset)
    ld d, a : call findRow
    ex de, hl
    ld a, (Wifi.networks_count) : ld hl, offset : sub (hl)
    cp PER_PAGE
    jr c, .cont
    ld a, PER_PAGE
.cont
    ex de, hl 
    ld b, a
.showLoop
    push bc
    call Display.putStr
    push hl
    call Display.putC.cr
    pop hl
    pop  bc
    inc hl
    djnz .showLoop
    call showCursor
    ret

hideCursor:
    ld c, 107o
    jr cursor
showCursor:
    ld c, 160o
cursor:
    ld a,(cursor_position) :  inc a :call Display.setAttr
    ret

uiLoop:
    ld b, 15
.loop
    halt
    djnz .loop
    
    call Keyboard.inKey

    cp Keyboard.KEY_UP : jr z, cursorUp
    cp 'q' : jr z, cursorUp
    
    cp Keyboard.KEY_DN : jr z, cursorDown
    cp 'a' : jr z, cursorDown

    cp 13 : jp z, selectItem

    jr uiLoop

cursorDown:
    call hideCursor
    ld a, (cursor_position) : inc a
    cp PER_PAGE 
    jr c, .store
    ld a, (offset) : add PER_PAGE : ld (offset), a 
    xor a : ld (cursor_position), a
    call renderList
    jr uiLoop
.store
    ;; Don't move cursor if list finished
    ld b,a : ld a, (offset) : add b : ld hl, Wifi.networks_count : cp (hl) : jr nc, .back
    ld a, b
    ld (cursor_position), a
.back
    call showCursor
    jr uiLoop

cursorUp:
    call hideCursor
    ld a, (cursor_position) : and a : jr z, .page_up
    dec a : ld (cursor_position), a 
.back
    call showCursor
    jp uiLoop
.page_up
    ld a, (offset) : and a : jr z, .back
    sub PER_PAGE : ld (offset), a
    ld a, PER_PAGE - 1 : ld (cursor_position), a
    call renderList
    jr .back

; D = row number
findRow:
    ld hl, buffer
    ld a, d : and a : ret z
    xor a
.loop    
    ld bc, #ffff
    cpir
    dec d
    jr nz, .loop
    ret

selectItem:
    call hideCursor
    call topClean
    gotoXY 0,2 : printMsg .ssid
    gotoXY 1,3
    ld a, (cursor_position) : ld hl, offset : add (hl) : ld d, a : call findRow ;; HL = SSID NAME
    call Display.putStr

    gotoXY 0,5 : printMsg .pass
    setLineColor 3, 071o : setLineColor 6, 171o
.readPass
    gotoXY 1,6 : printMsg .pass_buffer : ld a, 219 : call Display.putC : ld a,' ' : call Display.putC
    
    ld b, 10
.waitLoop
    halt
    djnz .waitLoop

    call Keyboard.inKey
    cp Keyboard.KEY_BS : jr z, .removeChar
    cp 13 : jr z, .connect
    cp 32 : jr c, .readPass

    push af
    xor a : ld hl, .pass_buffer, bc, 42 : cpir
    dec hl
    pop af
    ld (hl), a
    xor a : inc hl : ld (hl), a
    jr .readPass
.removeChar
    xor a
    ld hl, .pass_buffer, bc, #ff : cpir
    push hl
        ld de, .pass_buffer + 1
        or a : sbc hl, de
        ld a, h : or l
    pop hl
    jr z, .readPass
    xor a
    dec hl : dec hl : ld (hl), a 
    jr .readPass
.connect
    gotoXY 1,6 : printMsg .pass_buffer : ld a, ' ' : call Display.putC : ld a,' ' : call Display.putC
    

    ld hl, .at_start : call Wifi.espSendZ
    ld a, (cursor_position) : ld hl, offset : add (hl) : ld d, a : call findRow ;; HL = SSID NAME
    call Wifi.espSendZ
    ld hl, .at_middle   : call Wifi.espSendZ
    ld hl, .pass_buffer : call Wifi.espSendZ
    EspCmdOkErr '"'
    jp c, Wifi.init.err 

    ifdef ESXCOMPAT
    call Compat.iwConfig
    endif

    call topClean
    setLineColor 3, 107o : setLineColor 6, 107o
    gotoXY 0, 2
    printMsg .done

    jr $
.done      db "All done!", 13, 13, "Now you can use network apps!",13, 0
.at_start  db 'AT+CWJAP="',0
.at_middle db '","', 0

.ssid db "Selected SSID:", 0
.pass db "Enter password for SSID:", 0
.pass_buffer 
    ds 42

cursor_position db 0
offset db 0

msg_head
    ds 10, 196 
    db 180, "Network  Manager "
    db VERSION_STRING
    db 195 ; 17
    ds 10, 196
    db 0
msg_log 
    ds 16, 196
    db 180, "UART Log", 195
    ds 16, 196
    db 0 

    endmodule