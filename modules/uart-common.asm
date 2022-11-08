    module Uart
init:
    ld hl, .msg : call Display.putStrLog
    call UartImpl.init
    ret
.msg db "Preparing UART and setting port speed", 13,13,0

write:
    push af
    call UartImpl.write
    pop af
    jp Display.putLogC
  

writeStringZ:
    push hl
    call Display.putStrLog
    pop hl
.loop
    ld a,(hl) : and a : ret z
    push hl
    call UartImpl.write
    pop hl
    inc hl
    jr .loop

read:
    call UartImpl.read
    push af
    call Display.putLogC
    pop af
    ret

    endmodule
