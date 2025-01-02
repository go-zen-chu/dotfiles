#Requires AutoHotkey v2.0

; swap semicolon & colon for vim
*vkBA::{
    If (GetKeyState("Shift")){
        Send "`;"
    }
    else {
        Send ":"
    }
}

LWin::LAlt

; CapsLock を Control, LCtrl などに割り当てるとなぜか入力がバグる
CapsLock::LWin

LAlt::vk1D ; LAlt to Muhenkan
RAlt::vk1C ; RAlt to Henkan
