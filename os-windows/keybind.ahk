#Requires AutoHotkey v2.0
; swap semicolon & colon for vim
*vkBA::
    {
        If (GetKeyState("Shift")){
            Send "`;"
        }
        else {
            Send ":"
        }
    }
return

LWin::LAlt
CapsLock::LWin
LAlt::vk1D