MsgBox, Advanced Triggerbot Activated. Get tappin'.
; Note: Works best in full screen, low graphics settings for Da Hood. Ensure FOV and sensitivity are calibrated.

; Initialization
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode, Input
CoordMode, Pixel, Screen

; Configuration
key_hold_mode := "-" ; Toggle On / Off
key_exit := "End" ; Panic key
key_hold := "RButton" ; Button to hold for triggerbot

pixel_box := 10 ; Initial FOV (in pixels)
pixel_sens := 50 ; Color Sensitivity
pixel_color := ["0xFF5733", "0x33FF57"] ; Common player colors in Da Hood (adjust as needed)

click_delay := 10 ; Delay in MS between shots
fov_expand_rate := 5 ; Rate of FOV expansion
fov_max := 100 ; Max FOV expansion size
smooth_cursor := true ; Smooth cursor movement
cursor_speed := 5 ; Cursor movement speed
debug_mode := true ; Show debug information on-screen

; Additional Features
auto_shoot := true ; Automatically fire when a target is found
tracking_mode := true ; Smoothly track targets before shooting

; Screen Center
center_x := A_ScreenWidth // 2
center_y := A_ScreenHeight // 2
SetFOVBounds()

; Hotkeys
Hotkey, %key_hold_mode%, ToggleHoldMode
Hotkey, %key_exit%, Terminate
return

; Functions
SetFOVBounds() {
    global pixel_box, center_x, center_y, leftbound, rightbound, topbound, bottombound
    leftbound := center_x - pixel_box
    rightbound := center_x + pixel_box
    topbound := center_y - pixel_box
    bottombound := center_y + pixel_box
}

ToggleHoldMode:
global toggle
toggle := !toggle
if (toggle) {
    DebugMessage("Triggerbot Activated.")
    SetTimer, SearchLoop, 1
} else {
    DebugMessage("Triggerbot Deactivated.")
    SetTimer, SearchLoop, Off
    pixel_box := 10 ; Reset FOV
    SetFOVBounds()
}
return

Terminate:
ExitApp
return

SearchLoop:
While toggle and GetKeyState(key_hold, "P") {
    DetectAndShoot()
}
return

DetectAndShoot() {
    global auto_shoot, tracking_mode
    ; Search for targets
    for index, color in pixel_color {
        PixelSearch, FoundX, FoundY, leftbound, topbound, rightbound, bottombound, %color%, pixel_sens, Fast RGB
        if (!ErrorLevel) {
            ; Smoothly track the target if enabled
            if (tracking_mode)
                SmoothCursor(FoundX, FoundY)
            if (auto_shoot and !GetKeyState("LButton"))
                ClickTarget(FoundX, FoundY)
            ResetFOV()
            return
        }
    }
    ExpandFOV()
    return
}

SmoothCursor(x, y) {
    global smooth_cursor, cursor_speed
    if (smooth_cursor) {
        MouseMove, %x%, %y%, cursor_speed
    } else {
        MouseMove, %x%, %y%, 0
    }
}

ClickTarget(x, y) {
    global click_delay, debug_mode
    SendInput, {Click}
    DebugMessage("Target Hit at X: " x ", Y: " y)
    Sleep, click_delay
}

ExpandFOV() {
    global pixel_box, fov_expand_rate, fov_max
    if (pixel_box < fov_max) {
        pixel_box += fov_expand_rate
        SetFOVBounds()
        DebugMessage("Expanding FOV: " pixel_box)
    }
}

ResetFOV() {
    global pixel_box
    pixel_box := 10 ; Reset to initial FOV
    SetFOVBounds()
}

DebugMessage(msg) {
    global debug_mode
    if (debug_mode) {
        Tooltip, %msg%
        SetTimer, ClearTooltip, -1000
    }
}

ClearTooltip() {
    Tooltip
}
