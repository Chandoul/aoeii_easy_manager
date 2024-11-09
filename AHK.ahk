#Include SharedLib.ahk
AoEIIAIO.Title := 'GAME SHORTCUTS'
If !DirExist('Shortcuts') {
    DirCreate('Shortcuts')
}
Features['Macro'] := []
Add := AoEIIAIO.AddButton('w200', 'Add Shortcut')
Add.SetFont('Bold')
CreateImageButton(Add, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
Add.OnEvent('Click', CreateMacro)
List := AoEIIAIO.AddListBox('wp r15 0x100')
List.OnEvent('Change', DisplayContent)
RunMacro := AoEIIAIO.AddButton('ym w200', 'Run')
RunMacro.OnEvent('Click', RunM)
CreateImageButton(RunMacro, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
StopMacro := AoEIIAIO.AddButton('xp+300 ym w200', 'Stop')
StopMacro.OnEvent('Click', Stop)
CreateImageButton(StopMacro, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
Content := AoEIIAIO.AddEdit('xp-300 yp+37 r14 w500 cYellow Background1E1E1E HScroll')
Content.SetFont(, 'Consolas')
Content.OnEvent('Change', UpdateSave)
Remove := AoEIIAIO.AddButton('xm w200', 'Remove Shortcut')
Remove.SetFont('Bold')
CreateImageButton(Remove, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
Remove.OnEvent('Click', RemoveMacro)
Save := AoEIIAIO.AddButton('xm+510 yp w200 Disabled', 'Save')
Save.SetFont('Bold')
CreateImageButton(Save, 0, [[0xFFFFFF,, 0x0000FF, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
Save.OnEvent('Click', SaveMacro)
AoEIIAIO.Show()
GameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['Fixes'] {
        Fix.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
; Exits the scripts
AoEIIAIO.OnEvent('Close', ExitScript, 0)
AoEIIAIO.OnEvent('Close', ExitScriptA)
ExitScriptA(HGUI) {
    For Each, Script in Features['Macro'] {
        If WinExist('Shortcuts\' Script) {
            ProcessClose(WinGetPID('Shortcuts\' Script))
        }
    }
}
LoadMacro()
; Enable or disable the save button
UpdateSave(Ctrl, Info) {
    If (!List.Value || Ctrl.Value = FileRead('Shortcuts\' List.Text)) {
        if Save.Enabled {
            Save.Enabled := False
        }
    } Else {
        If !Save.Enabled {
            Save.Enabled := True
        }
    }
}
; Saved a macro
SaveMacro(Ctrl, Info) {
    Try {
        If !List.Value {
            Return
        }
        M := FileOpen('Shortcuts\' List.Text, 'w')
        M.Write(Content.Value)
        M.Close()
        UpdateSave(Content, Info)
    } Catch Error As Err {
        MsgBox("Hotkey save failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
; Removes a macro
RemoveMacro(Ctrl, Info) {
    Try {
        If !List.Value || 'Yes' != MsgBox('Are you sure to remove ' List.Text ' ?', 'Remove', 0x40 + 0x4) {
            Return
        }
        Stop(Ctrl, Info)
        FileDelete('Shortcuts\' List.Text)
        LoadMacro()
        DisplayContent(List, Info)
    } Catch Error As Err {
        MsgBox("Hotkey remove failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
; Creates a macro
CreateMacro(Ctrl, Info) {
    MName := InputBox('Enter the script name: ', 'New Macro', 'w400 h100', '')
    If MName.Result != 'OK' {
        Return
    }
    Try {
        MName.Value := MName.Value '.ahk'
        If FileExist('Shortcuts\' MName.Value) {
            MsgBox('Script already created!', 'Found Macro', 0x40)
            Return
        }
        FileAppend(';------------------------------------------------------;'
                 . '`n; Visit https://www.autohotkey.com/docs/v2/Hotkeys.htm `;'
                 . '`n; For more information                                 `;'
                 . '`n;------------------------------------------------------;'
                 . '`n#Requires AutoHotkey v2.0'
                 . '`n#SingleInstance Force'
                 . '`n`n; Write below your custom macro`n', 'Shortcuts\' MName.Value)
        List.Add([MName.Value])
        List.Choose(MName.Value)
        DisplayContent(List, Info)
    } Catch Error As Err {
        MsgBox("Hotkey create failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
; Loads found macros
LoadMacro() {
    Try {
        List.Delete()
        Loop Files, 'Shortcuts\*.ahk' {
            List.Add([A_LoopFileName])
            Run('Shortcuts\' A_LoopFileName)
            Features['Macro'].Push(A_LoopFileName)
        }
    } Catch Error As Err {
        MsgBox("Hotkey set failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
; Shows the script content
DisplayContent(Ctrl, Item) {
    Content.Value := ''
    If Ctrl.Text {
        Content.Value := FileRead('Shortcuts\' Ctrl.Text)
    }
    UpdateSave(Content, Item)
}
; Stops a ran macro
Stop(Ctrl, Info) {
    If WinExist(List.Text) {
        ProcessClose(WinGetPID('Shortcuts\' List.Text))
    }
}
; Runs a macro
RunM(Ctrl, Info) {
    Run('Shortcuts\' List.Text)
}