#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

; --- Initial Variables ---
Global Build :=  "2.0"
Global Version := "1.1A"

Global LoopDelay := 250 
Global RebirthDelay := 2500 
Global CrunchKey := "c"
Global MaxAllKey := "m"
Global AutoTabKey := "a"
Global BoostKey := "d"
Global GalaxyKey := "g"
Global SacKey := "s"
Global TargetWin := "Antimatter Dimensions"
Global GuiTitle := "AD Automation Pro"

; State Tracking
Global IsLooping := false
Global IsHolding := false
Global IsRebirthing := false

; --- Create the GUI ---
MyGui := Gui("+AlwaysOnTop", GuiTitle)
MyGui.SetFont("s10", "Segoe UI")
MyGui.Add("Text", "w0 h0 +ReadOnly", "") 

TabObj := MyGui.Add("Tab3", "w280 h280", ["Delays", "Keybinds", "Controls"])

; --- Tab 1: Delays ---
TabObj.UseTab(1)
MyGui.Add("Text", "y+10", "Max All Interval (ms):")
Global EditDelay := MyGui.Add("Edit", "vDelay w80 +Number", LoopDelay)
MyGui.SetFont("s8 cGray")
MyGui.Add("Text", "y+2", "Automation pauses when game is not focused.")
MyGui.SetFont("s10 cDefault")
MyGui.Add("Text", "y+10", "Rebirth Interval (ms):")
Global EditRebirthDelay := MyGui.Add("Edit", "vRebirthDelay w80 +Number", RebirthDelay)

; --- Tab 2: Keybinds ---
TabObj.UseTab(2)
MyGui.Add("Text", "y+10", "Max All:")
Global EditMaxKey := MyGui.Add("Edit", "w30 Limit1", MaxAllKey)
MyGui.Add("Text", "x+10", "Crunch:")
Global EditCrunchKey := MyGui.Add("Edit", "w30 Limit1", CrunchKey)
MyGui.Add("Text", "x15 y+10", "Boost (D):")
Global EditBoostKey := MyGui.Add("Edit", "w30 Limit1", BoostKey)
MyGui.Add("Text", "x+10", "Galaxy (G):")
Global EditGalaxyKey := MyGui.Add("Edit", "w30 Limit1", GalaxyKey)
MyGui.Add("Text", "x+10", "Sacrifice (S):")
Global EditSacKey := MyGui.Add("Edit", "w30 Limit1", SacKey)
MyGui.Add("Text", "x15 y+10", "Auto Tab:")
Global EditAutoKey := MyGui.Add("Edit", "w30 Limit1", AutoTabKey)

; --- Tab 3: Controls ---
TabObj.UseTab(3)
MyGui.Add("Text", "y+5 cGreen", "Q - Apply Settings")
MyGui.Add("Text", "y+2 cRed", "E - Stop All")
MyGui.Add("Text", "y+2 cBlack", "Z - Exit Script")
MyGui.Add("Text", "w240 h2 +0x10") 
MyGui.Add("Text", "y+5 cBlue", "Shift + 1: Toggle Max All")
MyGui.Add("Text", "y+2 cBlue", "Shift + 2: Toggle Hold Crunch")
MyGui.Add("Text", "y+2 cBlue", "Shift + 3: Toggle Auto Tab")
MyGui.Add("Text", "y+2 cPurple", "Shift + 4: Toggle Rebirths")

; --- Global Buttons ---
TabObj.UseTab() 
MyGui.Add("Button", "Default w70 x40 y300", "Run (Q)").OnEvent("Click", StartScript)
MyGui.Add("Button", "w70 x+10", "Stop (E)").OnEvent("Click", (*) => StopAutomation())
MyGui.Add("Button", "w70 x+10", "Exit (Z)").OnEvent("Click", (*) => ExitApp())

MyGui.Show()

; --- Focus Monitor ---
SetTimer(WatchFocus, 500)
WatchFocus() {
    if !WinActive(TargetWin) && IsHolding {
        Send("{" . CrunchKey . " up}")
    }
}

; --- Logic Functions ---
StartScript(*) {
    global LoopDelay, RebirthDelay, MaxAllKey, CrunchKey, AutoTabKey, BoostKey, GalaxyKey, SacKey
    global IsLooping, IsHolding, IsRebirthing, TargetWin

    LoopDelay := (EditDelay.Value != "") ? EditDelay.Value : 100
    RebirthDelay := (EditRebirthDelay.Value != "") ? EditRebirthDelay.Value : 1000
    MaxAllKey := (EditMaxKey.Value != "") ? EditMaxKey.Value : "m"
    CrunchKey := (EditCrunchKey.Value != "") ? EditCrunchKey.Value : "c"
    AutoTabKey := (EditAutoKey.Value != "") ? EditAutoKey.Value : "a"
    BoostKey := (EditBoostKey.Value != "") ? EditBoostKey.Value : "d"
    GalaxyKey := (EditGalaxyKey.Value != "") ? EditGalaxyKey.Value : "g"
    SacKey := (EditSacKey.Value != "") ? EditSacKey.Value : "s"

    if (IsLooping)
        SetTimer(SendMax, LoopDelay)
    else
        SetTimer(SendMax, 0)

    if (IsRebirthing)
        SetTimer(SendRebirths, RebirthDelay)
    else
        SetTimer(SendRebirths, 0)

    if (IsHolding) {
        if WinActive(TargetWin)
            Send("{" . CrunchKey . " down}")
    } else {
        Send("{" . CrunchKey . " up}")
    }

    ToolTip("Settings Applied")
    SetTimer(() => ToolTip(), -2000)
}

StopAutomation() {
    global IsLooping, IsHolding, IsRebirthing
    SetTimer(SendMax, 0)
    SetTimer(SendRebirths, 0)
    IsLooping := false
    IsHolding := false
    IsRebirthing := false
    Send("{" . CrunchKey . " up}")
    ToolTip("!!! ALL AUTOMATION STOPPED !!!")
    SetTimer(() => ToolTip(), -2000)
}

; --- THE BUG FIX: CONTEXTUAL HOTKEYS ---

; This section makes Q, E, and Z only work as script controls 
; IF the Game OR the Settings GUI is focused.
#HotIf WinActive(TargetWin) or WinActive(GuiTitle)

$q:: {
    ; Only let letters through when the settings GUI is focused and the user is typing in a control
    if (WinActive(GuiTitle) && ControlGetFocus(WinActive("A")) != 0 && !InStr(ControlGetFocus(WinActive("A")), "Button"))
        Send("q")
    else
        StartScript()
}

$e:: {
    if (WinActive(GuiTitle) && ControlGetFocus(WinActive("A")) != 0 && !InStr(ControlGetFocus(WinActive("A")), "Button"))
        Send("e")
    else
        StopAutomation()
}

$z:: {
    if (WinActive(GuiTitle) && ControlGetFocus(WinActive("A")) != 0 && !InStr(ControlGetFocus(WinActive("A")), "Button"))
        Send("z")
    else
        ExitApp()
}

; Shift toggles already only work in-game
+1:: { 
    global IsLooping := !IsLooping
    SetTimer(SendMax, IsLooping ? LoopDelay : 0)
    ToolTip("Looping [" . MaxAllKey . "]: " . (IsLooping ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}

+2:: { 
    global IsHolding := !IsHolding
    if (IsHolding)
        Send("{" . CrunchKey . " down}")
    else
        Send("{" . CrunchKey . " up}")
    ToolTip("Holding [" . CrunchKey . "]: " . (IsHolding ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}

+3:: { 
    global AutoTabKey
    Send(AutoTabKey) 
    ToolTip("Toggled Automation Tab")
    SetTimer(() => ToolTip(), -1500)
}

+4:: { 
    global IsRebirthing := !IsRebirthing
    SetTimer(SendRebirths, IsRebirthing ? RebirthDelay : 0)
    ToolTip("Rebirth Automation: " . (IsRebirthing ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}

#HotIf ; Reset Context

; --- Helper Functions ---
SendMax() {
    global MaxAllKey, TargetWin
    if WinActive(TargetWin)
        Send(MaxAllKey)
}

SendRebirths() {
    global BoostKey, GalaxyKey, SacKey, TargetWin
    if WinActive(TargetWin) {
        Send(BoostKey), Sleep(50)
        Send(GalaxyKey), Sleep(50)
        Send(SacKey)
    }
}
