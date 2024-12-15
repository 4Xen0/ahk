MsgBox, Get tappin lil cunt
; Note: Works on any resolution. Ensure full screen and low graphics settings for best performance.

; Initialize
#Persistent
#MaxThreadsPerHotkey 2
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
CoordMode, Pixel, Screen

; Configuration
key_hold_mode := "-" ; To toggle On / Off
key_exit := "End" ; Panic key
key_hold := "RButton" ; Button / Key to hold to use

pixel_box := 5 ; Fov (In Pixels)
pixel_sens := 55 ; Color Sensitivity (lower it to make it detect fewer shades, higher to detect more)
pixel_color := ["0x000000", "0xFFFFFF"] ; Black and White colors

click_delay := 15 ; Delay in MS
debug_mode := true ; Set to true to display debug messages
smooth_cursor := true ; Set to true for smooth cursor movement
cursor_speed := 5 ; Speed of cursor movement (lower = slower, higher = faster)
fov_expand_rate := 10 ; Rate at which FOV expands dynamically
fov_max := 100 ; Max FOV expansion size

; Calculate Screen Bounds (Centered FOV)
original_pixel_box := pixel_box ; Save original FOV
center_x := A_ScreenWidth // 2
center_y := A_ScreenHeight // 2
SetFOVBounds()

; Hotkey Setup
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
    pixel_box := original_pixel_box ; Reset FOV
    SetFOVBounds()
}
return

Terminate:
ExitApp
return

SearchLoop:
While toggle and GetKeyState(key_hold, "P") {
    PixelSearchAdvanced()
}
return

PixelSearchAdvanced() {
    global
    ; Iterate through target colors
    for index, color in pixel_color {
        PixelSearch, FoundX, FoundY, leftbound, topbound, rightbound, bottombound, %color%, pixel_sens, Fast RGB
        if (!ErrorLevel) {
            ; Target found
            if (!GetKeyState("LButton")) {
                ClickPixel(FoundX, FoundY)
                Sleep, click_delay
            }
            pixel_box := original_pixel_box ; Reset FOV
            SetFOVBounds()
            return
        }
    }
    ; Expand FOV if no target is found
    ExpandFOV()
    return
}

ClickPixel(x, y) {
    global debug_mode, smooth_cursor, cursor_speed
    ; Move cursor to the target and click
    if (smooth_cursor)
        MouseMove, %x%, %y%, cursor_speed ; Smooth mouse movement
    else
        MouseMove, %x%, %y%, 0 ; Instant mouse movement

    SendInput, {Click}
    DebugMessage("Clicked at X: " x ", Y: " y)
}

ExpandFOV() {
    global pixel_box, fov_expand_rate, fov_max
    if (pixel_box < fov_max) {
        pixel_box += fov_expand_rate
        SetFOVBounds()
        DebugMessage("Expanding FOV: " pixel_box " pixels")
    }
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
