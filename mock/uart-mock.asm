;;;
;;; This is mock implementation of UART driver - developed just for testing purpouses
;;;
    module UartImpl
;; Nothing to init
init:
    ret

;; Yeees, we written it :D
write:
    ret

;; Fake reading from uart 
read:
    ld hl, (read_ptr)
    ld a,(hl)
    inc hl
    ld (read_ptr), hl
    ret


read_ptr dw fake_buffer

fake_buffer incbin "uart-log.txt"

    endmodule