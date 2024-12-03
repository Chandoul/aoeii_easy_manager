#Requires AutoHotkey v2
#SingleInstance Force

#Include <ValidGame>
#Include <ReadWriteJSON>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')

AoEIIAIO := Gui(, 'RPG Maps')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')
ScxList := AoEIIAIO.AddListView('w300 r15', ['Filename'])
ScxList.OnEvent('ItemSelect', StrutureParse)
AoEIIAIO.SetFont('norm')
InfoStr := AoEIIAIO.AddEdit('yp w400 ReadOnly cRed Center BackgroundWhite')
ValueStr := AoEIIAIO.AddEdit('w400 r14 HScroll ReadOnly BackgroundWhite')
Copy := AoEIIAIO.AddButton('w400', 'Copy')
AoEIIAIO.Show()
If !ValidGameDirectory(GameDirectory) {
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
Loop Files, GameDirectory '\Scenario\*.scx'
    ScxList.Add(, A_LoopFileName)

StrutureParse(Ctrl, Item, Info) {
    File := GameDirectory '\Scenario\' Ctrl.GetText(Item)
    Obj := FileOpen(File, 'r')
    Buff := Buffer(4), Obj.RawRead(Buff, 4)
    Version := StrGet(Buff, 4, 'cp0')
    InfoStr.Value := 'Version: ' Version
    Obj.Pos := 16
    Buff := Buffer(4), Obj.RawRead(Buff, 4)
    InstructionsLen := NumGet(Buff, 0, 'UInt')
    Buff := Buffer(InstructionsLen), Obj.RawRead(Buff, InstructionsLen)
    Instructions := StrGet(Buff, InstructionsLen, 'cp0')
    ValueStr.Value := Instructions
}