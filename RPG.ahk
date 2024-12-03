#Requires AutoHotkey v2
#SingleInstance Force

#Include <ValidGame>
#Include <ReadWriteJSON>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')

AoEIIAIO := Gui(, 'DIRECT DRAW FIX')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')
MsgBox('Comming soon!', 'Info', 0x40)
ExitApp()
AoEIIAIO.Show()
If !ValidGameDirectory(GameDirectory) {
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}