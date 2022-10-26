    module Keyboard
BASIC_KEY = #5C08
KEY_BS = 12
KEY_UP = 11
KEY_DN = 10

inKey:
    ld a,(BASIC_KEY)
    and a : jr z, inKey
    ld c, a
    xor a : ld (BASIC_KEY),a
    ld a, c
    ret

    endmodule