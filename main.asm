    device ZXSPECTRUM48
origin = #8000
    org origin
    jp start
    include "modules/version.asm"
    include "modules/display.asm"
    include "modules/wifi.asm"
    include "modules/ui.asm"
    include "modules/uart-common.asm"
    include "modules/keyboard.asm"

    ifdef ESXCOMPAT
    include "modules/compat.asm"
    endif

    ifdef UNO
    include "drivers/zxuno.asm"
    endif

    ifdef AY
    include "drivers/ay.asm"
    endif

    ifdef NEXT
    include "drivers/next.asm"
    endif

start:
    call UI.init
    call Uart.init
    call Wifi.init
    call Wifi.getList
    call UI.renderList
    jp   UI.uiLoop
buffer equ $
    ifndef HOB
    save3dos "netman.cod", origin, $ - origin
    else
    savehob "netman.$c", "netman.C", origin, $ - origin
    endif
