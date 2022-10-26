    org #8000
    device zxspectrum128
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    define V 20
    define ESXCOMPAT 1
stack_top:
    include "modules/version.asm"
    include "modules/display.asm"
    include "modules/wifi.asm"
    include "modules/ui.asm"
    include "modules/uart-common.asm"
    include "modules/keyboard.asm"
    include "modules/compat.asm"
    include "mock/uart-mock.asm"
start:
    ei
    call UI.init
    call Uart.init
    call Wifi.init
    call Wifi.getList
    call UI.renderList
    jp   UI.uiLoop

buffer equ $
    savesna "test.sna", start