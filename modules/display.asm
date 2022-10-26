    module Display
scr_addr = #4000

; a - line number
; c - color
setAttr:
	rrca
	rrca
	rrca
	ld	l,a
	and	31
	or	#58
	ld	h,a
	ld	a,l
	and	252
	ld	l,a

    ld de, hl
    inc de
    ld a, c : ld (hl), a
    ld bc, #1f
    ldir
    ret

putStr:
    ld a, (hl) : and a : ret z
    push hl
    call putC
    pop hl
    inc hl
    jr putStr

putStrLog:
    ld a, (hl) : and a : ret z
    push hl
    call putLogC
    pop hl
    inc hl
    jr putStrLog

putC:
    cp 13 : jr z, .cr
    ld hl, (coords) : ld (drawC.coords), hl
    call drawC
    ld hl, coords
    inc (hl)
    ld a,(hl) : cp 42 : jr nc, .cr
    ret
.cr
    ld hl, coords
    xor a : ld (hl), a
    inc hl : inc (hl)
    ret

putLogC:
    cp 13 : jr z, .cr
    cp ' ' : ret c
    ld c,a
    ld h, 22
    ld a, (.coord), l, a
    ld (drawC.coords), hl
    ld a,c
    call drawC
    ld hl, .coord : inc (hl) : ld a,(hl)
    cp 42 : ret c
.cr
    xor a : ld (.coord), a
.scrollLog
    ld hl, #5000
    dup 8
    ld de, hl
    inc de
    ld bc, 31
    xor a : ld (hl), a
    ldir

    ld de, #100 - #1f
    add hl, de
    edup

    ld de, #5000
    ld hl, #5020
    ld bc, #800-#20
    ldir
    ret
.coord db 0

drawC:
    ld (.char_tmp),a
    ld hl, 0
.coords = $ - 2
    ld b, l
    call calc
    ld d, h
    ld e, l
    ld (.rot_tmp), a
    call findAddr

;; Get char
    ld a, 0
.char_tmp = $ - 1
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, font
    add hl, bc
    push hl, de
;; Mask rotation
    ld a, (.rot_tmp)
    ld hl, #03ff
    and a : jr z, .drawIt
.rot_loop
    ex af, af
    ld a,l
    rrca
    rr h
    rr l
    ex af, af
    dec a
    jr nz, .rot_loop
.drawIt    
    ld a, l
    ld (.mask1), a
    ld a, h
    ld (.mask2), a
    pop ix, de 
;; Basic draw
    ld a, 0
.rot_tmp = $ - 1
    ld (.rot_cnt), a
    ld b, 8
.printIt
    ld a, (de)
    ld h,a
    ld l,0
    ld a,0
.rot_cnt = $ - 1
    and a : jr z, .skipRot
.rotation
    ex af, af
    ld a, l
    rrca
    rr h
    rr l
    ex af, af
    dec a
    jr nz, .rotation
.skipRot
    ld a, (ix + 1)
    and #0f
.mask1 = $ - 1
    or l
    ld (ix + 1), a
    ld a, (ix)
    and #fc
.mask2 = $ - 1
    or h
    ld (ix), a
    inc ixh
    inc de
    djnz .printIt
    ret

clrTop:
    ld hl, #4000
    ld de, #4001
    ld bc, #fff
    xor a 
    ld (hl),a
    ldir
    ret
clrscr:
    xor a
    out (#fe), a

    ld hl, #4000
    ld de, #4001
    ld bc, #17ff
    ld (hl),a
    ldir

    ld a, 107O
    ld hl, #5800
    ld de, #5801
    ld bc, #200
    ld (hl), a
    ldir
    
    ld a, 014o : ld (hl),a
    ld bc, #ff
    ldir
    ret

; DE -> DE
findAddr:
    LD A,D
    AND 7
    RRCA
    RRCA
    RRCA
    OR E
    LD E,A
    LD A,D
    AND 24
    OR #40
    LD D,A
    ret

; in:   b - x column in 42 symbols per line
; out:  l - x column in 32 symbols per line
;       a - offset in pixels
calc
      ld l,0
      sub a
      ld c,6
1     add a,c
      djnz 1b
2     cp 8
      ret c
      sub 8
      inc l
      jr 2b

coords dw 0
font incbin "font.bin"    
    endmodule

    macro setLineColor line, color
    ld a, line, c, color
    call Display.setAttr
    endm

    macro gotoXY x, y
    ld hl, x or (y<<8)
    ld (Display.coords), hl
    endm

    macro printMsg ptr
    ld hl, ptr : call Display.putStr
    endm