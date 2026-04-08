#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

; --- Initial Variables ---
Global Build :=  "2.1"
Global Version := "1.1B"

Global LoopDelay := 250 
Global RebirthDelay := 2500 
Global CrunchKey := "c"
Global MaxAllKey := "m"
Global AutoTabKey := "a"
Global BoostKey := "d"
Global GalaxyKey := "g"
Global SacKey := "s"
Global TargetWin := "Antimatter Dimensions"
Global GuiTitle := "AD Automation"

; State Tracking
Global IsLooping := false
Global IsHolding := false
Global IsRebirthing := false

; --- Create the GUI ---
MyGui := Gui("+AlwaysOnTop", GuiTitle)
MyGui.SetFont("s10", "Segoe UI")
MyGui.Add("Text", "w0 h0 +ReadOnly", "") 

TabObj := MyGui.Add("Tab3", "w240 h280", ["Delays", "Keybinds", "Controls", "Credits"])

^1:: TabObj.Value := 1
^2:: TabObj.Value := 2
^3:: TabObj.Value := 3
^4:: TabObj.Value := 4

; --- Tab 1: Delays ---
TabObj.UseTab(1)
MyGui.Add("Text", "x15 y+10", "Max All Interval (ms):")
Global EditDelay := MyGui.Add("Edit", "vDelay w80 +Number", LoopDelay)
Global MaxAllButton := MyGui.Add("Button", "w50 x+10", "Off").OnEvent("Click", ToggleMaxAllButtonClick)

ToggleMaxAllButtonClick(GuiCtrlObj, Info) {
    global IsLooping, LoopDelay
    IsLooping := !IsLooping
    GuiCtrlObj.Text := IsLooping ? "On" : "Off"
    ToolTip("Max All: " . (IsLooping ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}
MyGui.SetFont("s8 cGray")
MyGui.SetFont("s10 cDefault")
MyGui.Add("Text", "x15 y+10", "Rebirth Interval (ms):")
Global EditRebirthDelay := MyGui.Add("Edit", "vRebirthDelay w80 +Number", RebirthDelay)
MyGui.Add("Button", "w50 x+10", "Off").OnEvent("Click", ToggleRebirths)
ToggleRebirths(GuiCtrlObj, Info) {
    global IsRebirthing
    IsRebirthing := !IsRebirthing
    GuiCtrlObj.Text := IsRebirthing ? "On" : "Off"
    ToolTip("Rebirth Automation: " . (IsRebirthing ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}
MyGui.Add("Text", "y+20 x20", "Automation pauses when the game")
MyGui.Add("Text", "y+2 x20", "is not focused.")

; --- Tab 2: Keybinds ---
TabObj.UseTab(2)
MyGui.Add("Text", "x15 y+10", "Max All:")
Global EditMaxKey := MyGui.Add("Edit", "w30 Limit1", MaxAllKey)
MyGui.Add("Text", "x+15", "Crunch:")
Global EditCrunchKey := MyGui.Add("Edit", "w30 Limit1", CrunchKey)
MyGui.Add("Text", "x15 y+10", "Boost (D):")
Global EditBoostKey := MyGui.Add("Edit", "w30 Limit1", BoostKey)
MyGui.Add("Text", "x+15", "Galaxy (G):")
Global EditGalaxyKey := MyGui.Add("Edit", "w30 Limit1", GalaxyKey)
MyGui.Add("Text", "x+15", "Sacrifice (S):")
Global EditSacKey := MyGui.Add("Edit", "w30 Limit1", SacKey)
MyGui.Add("Text", "x15 y+10", "Auto Tab:")
Global EditAutoKey := MyGui.Add("Edit", "w30 Limit1", AutoTabKey)

; --- Tab 3: Controls ---
TabObj.UseTab(3)
MyGui.Add("Text", "y+5 cGreen", "Q - Apply Settings")
MyGui.Add("Text", "y+2 cRed", "E - Stop All")
MyGui.Add("Text", "y+2 cBlack", "Z - Exit Script")
MyGui.Add("Text", "w213 h1 +0x5") 
MyGui.Add("Text", "y+5 cBlue", "Shift + 1: Toggle Max All")
MyGui.Add("Text", "y+2 cBlue", "Shift + 2: Toggle Hold Crunch")
MyGui.Add("Text", "y+2 cBlue", "Shift + 3: Toggle Auto Tab")
MyGui.Add("Text", "y+2 cBlue", "Shift + 4: Toggle Rebirths")
MyGui.Add("Text", "w213 h1 +0x5") 
MyGui.Add("Text", "y+5 c808000", "Ctrl+1: Delays Tab Keybind")
MyGui.Add("Text", "y+2 c808000", "Ctrl+2: Keybinds Tab Keybind")
MyGui.Add("Text", "y+2 c808000", "Ctrl+3: Controls Tab Keybind")
MyGui.Add("Text", "y+2 c808000", "Ctrl+4: Credits Tab Keybind")

; --- Tab 4: Credits ---
TabObj.UseTab(4)
MyGui.Add("Text", "y+10 c808000", "Antimatter Dimensions")
MyGui.Add("Text", "y+2 c808000", "Automatic Grind Script")
MyGui.Add("Text", "y+5 cDefault", "") ; Use blank text for spacing
MyGui.Add("Text", "y+5 cDefault", "Version: " . Version . " (Build " . Build . ")")
MyGui.Add("Text", "y+5 cDefault", "Created by: FishyTheBlox")
MyGui.Add("Text", "y+5 cDefault", "") ; Use blank text for spacing
MyGui.Add("Link", "y+5", 'GitHub: <a href="https://github.com/FishyTheBlox">FishyTheBlox</a>')
MyGui.Add("Link", "y+5", 'Discord: <a href="https://discord.gg/N9yxBwatdz">the.fishy.guy</a>')
MyGui.Add("Text", "y+5 cDefault", "") ; Use blank text for spacing
MyGui.Add("Text", "y+10 c008000", "Special thanks to everyone")
MyGui.Add("Text", "y+2 c008000", "who has tested this script!")

; --- Global Buttons ---
TabObj.UseTab() 
MyGui.Add("Button", "Default w70 x15 y300", "Run (Q)").OnEvent("Click", StartScript)
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
ToggleMaxAll(*) {
    global IsLooping, LoopDelay
    IsLooping := !IsLooping
    SetTimer(SendMax, IsLooping ? LoopDelay : 0)
    ToolTip("Max All: " . (IsLooping ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -1500)
}

StartScript(*) {
    ToggleMaxAll()
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
