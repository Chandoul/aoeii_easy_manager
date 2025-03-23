#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ImageButton>
#Include <Json>
#Include <HashFile>

AoEIIAIO := Gui(, 'GAME SHORTCUTS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Segoe UI')

LV := AoEIIAIO.AddListView('w600 cGreen r10', ['Hotkey', 'Comment'])
LV.OnEvent('Click', ShowHotkey)
Try HotkeyDef := ReadHotkey()
Catch
    HotkeyDef := Map()
Script := "
(
    #Requires AutoHotkey v2
    #SingleInstance Force
    GroupAdd('AOKAOC', 'ahk_exe empires2.exe')
    GroupAdd('AOKAOC', 'ahk_exe age2_x1.exe')
    GroupAdd('AOKAOC', 'ahk_exe age2_x2.exe')
    #HotIf WinActive('ahk_group AOKAOC')
)"
For HotkeyName, HotOpt in HotkeyDef {
    LV.Add(, HotkeyName, '# ' HotOpt['Comment'])
    Script .= '`n' HotkeyName ':: {`n' HotOpt['Action'] '`n}'
}
Script .= '
(
    #HotIf
    ProcessWaitClose(A_Args[1])
    ExitApp()
)'
LV.ModifyCol(1, 'AutoHdr')

AoEIIAIO.SetFont('Norm s8')
Import := AoEIIAIO.AddButton('xm w100', 'Import')
Import.OnEvent('Click', (*) => Import_v2_4_Hotkeys())

Update := AoEIIAIO.AddButton('yp xm+500 w100', 'Save')
Update.OnEvent('Click', (*) => UpdateHotkeys())

AoEIIAIO.SetFont('s10')
AddHotName := AoEIIAIO.AddEdit('xm w600 cBlue')
AddHotName.OnEvent('Change', (*) => AutoSave())
AddHotCom := AoEIIAIO.AddEdit('w600 cGreen')
AddHotCom.OnEvent('Change', (*) => AutoSave())
AddHotAction := AoEIIAIO.AddEdit('w600 r10 cBlack')
AddHotAction.OnEvent('Change', (*) => AutoSave())

If FileExist('Shortcuts\Hotkeys.json') {
    Hash := HashFile('Shortcuts\Hotkeys.json')
    If !FileExist('Shortcuts\' Hash '.ahk') {
        FileAppend(Script, 'Shortcuts\' Hash '.ahk')
    }
    Run('Shortcuts\' Hash '.ahk ' ProcessExist())
}

If !DirExist('Shortcuts')
    DirCreate('Shortcuts')

AoEIIAIO.Show()

ShowHotkey(Ctrl, Info) {
    Key := Ctrl.GetNext()
    If !Key {
        Return
    }
    HotkeyDef := ReadHotkey()
    If HotkeyDef.Has(HK := Ctrl.GetText(Key)) {
        AddHotName.Value := HK
        AddHotCom.Value := HotkeyDef[HK]['Comment']
        AddHotAction.Value := HotkeyDef[HK]['Action']
    }
}

AutoSave() {
    If AddHotName.Value != '' {
        HotkeyDef[AddHotName.Value] := Map(
            'Action', AddHotAction.Value,
            'Comment', AddHotCom.Value
        )
    }
}

UpdateHotkeys() {
    FileObj := FileOpen('Shortcuts\Hotkeys.json', 'w')
    FileObj.Write(JSON.Dump(HotkeyDef, '`t'))
    FileObj.Close()
    If MsgBox('Changes are saved!`nTo take effect you need to reload the script, reload now?', 'Save', 0x40 + 0x4) = 'Yes' {
        Reload
    }
}

Import_v2_4_Hotkeys() {
    SearcDir := FileSelect('D')
    HotkeyDef := ReadHotkey()
    Loop Files, SearcDir '\*.ahk' {
        Content := FileRead(A_LoopFileFullPath)
        If RegExMatch(Content, "\QHotkey('\E(.*)\Q', Action)\E", &HKName) || RegExMatch(Content, "(.*)::", &HKName) {
            If HotkeyDef.Has(HKName[1])
                Continue
            HotkeyDef[HKName[1]] := Map()
        }
        If RegExMatch(Content, "s)Action\Q(*) \E{(.*)\Q}", &HKAction)
            HotkeyDef[HKName[1]]['Action'] := HKAction[1]

        If RegExMatch(Content, ";(.*)", &HKComment)
            HotkeyDef[HKName[1]]['Comment'] := HKComment[1]
    }
    UpdateHotkey(HotkeyDef)
    Reload()
}

UpdateHotkey(Keys) {
    O := FileOpen('Shortcuts\Hotkeys.json', 'w')
    O.Write(JSON.Dump(Keys, '`t'))
    O.Close()
}

ReadHotkey() {
    Try Return JSON.Load(FileRead('Shortcuts\Hotkeys.json'))
    Catch
        Return Map()
}