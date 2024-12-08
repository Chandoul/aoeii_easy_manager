#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ValidGame>
#Include <ReadWriteJSON>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
Data := []

AoEIIAIO := Gui(, 'RPG Maps')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')
ScxList := AoEIIAIO.AddListView('w300 h362 c000080 -Multi', ['Filename'])
ScxList.OnEvent('Click', StrutureParse)
Titles := AoEIIAIO.AddListView('yp w200 h362 c0000FF -Multi', ['Extracted Info'])
Titles.OnEvent('Click', ShowInfo)
InfoStr := AoEIIAIO.AddEdit('yp w500 ReadOnly cRed Center BackgroundWhite')
AoEIIAIO.SetFont('norm s10')
ValueStr := AoEIIAIO.AddEdit('w500 h293 HScroll ReadOnly BackgroundWhite')
Copy := AoEIIAIO.AddButton('w500', 'Copy')
Copy.OnEvent('Click', (*) => A_Clipboard := ValueStr.Value)
AoEIIAIO.Show()
If !ValidGameDirectory(GameDirectory) {
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
Files := []
Loop Files, GameDirectory '\*.scx', 'R'
    ScxList.Add(, A_LoopFileName), Files.Push(A_LoopFileFullPath)
ShowInfo(Ctrl, Item) {
    InfoStr.Value := Data[Item][1]
    ValueStr.Value := Data[Item][2]
}
StrutureParse(Ctrl, Item) {
    Global Data
    Name := Ctrl.GetText(Item)
    File := Files[Item]
    Obj := FileOpen(File, 'r')

    Data := []
    InfoStr.Value := ''
    ValueStr.Value := ''
    ; Version
    Version := ReadUChar(Obj, 4)
    Data.Push(['Version', Version])
    
    Obj.Pos += 12
    
    ;Instructions
    Instructions := ''
    If InstructionsLen := Obj.ReadUInt()
        Instructions := ReadUChar(Obj, InstructionsLen)
    Data.Push(['Instructions', Instructions])

    Obj.Pos += 4

    ; Players count
    PlayersCount := Obj.ReadUInt()
    Data.Push(['Players Count', PlayersCount])

    ; Decompress (Deflate method)
    If !DirExist('tmp\decomSCX')
        DirCreate('tmp\decomSCX')
    LeftLen := Obj.Length - Obj.Pos
    If !FileExist('tmp\decomSCX\' Name) {
        decObj := FileOpen('tmp\decomSCX\' Name, 'w')
        Loop LeftLen
            decObj.WriteUChar(Obj.ReadUChar())
        decObj.Close()
        ErrorCode := RunWait(A_Clipboard := 'Lib\py\zlib.exe "' A_ScriptDir '\tmp\decomSCX\' Name '" "' A_ScriptDir '\tmp\decomSCX\' Name '"')
        If ErrorCode {
            Msgbox('Unable to decode the scenario`n`nError Code: ' ErrorCode)
            Return
        }    
    }

    Obj.Close()
    Obj := FileOpen('tmp\decomSCX\' Name, 'r')

    Obj.Pos += 4

    ; Scenario version
    ScxVersion := Round(Obj.ReadFloat(), 2)
    Data.Push(['Scenario Version', ScxVersion])

    ; Seek
    Obj.Pos += 4096
    Obj.Pos += 64
    Obj.Pos += 256
    Obj.Pos += 1
    Obj.Pos += 2
    Obj.Pos += 2
    Obj.Pos += 4

    ; Scx Name
    NameLen := Obj.ReadUShort()
    ScxName := ReadUChar(Obj, NameLen)

    Obj.Pos += 24

    ; InstructionsTable
    Len := Obj.ReadUShort()
    InstructionsTable := ReadUChar(Obj, Len)
    Data.Push(['Instructions Table', InstructionsTable])

    ; HintsTable
    Len := Obj.ReadUShort()
    HintsTable := ReadUChar(Obj, Len)
    Data.Push(['Hints Table', HintsTable])

    ; VictoryTable
    Len := Obj.ReadUShort()
    VictoryTable := ReadUChar(Obj, Len)
    Data.Push(['Victory Table', VictoryTable])

    ; LossTable
    Len := Obj.ReadUShort()
    LossTable := ReadUChar(Obj, Len)
    Data.Push(['Loss Table', LossTable])

    ; HistoryTable
    Len := Obj.ReadUShort()
    HistoryTable := ReadUChar(Obj, Len)
    Data.Push(['History Table', HistoryTable])

    ; ScoutsTable
    Len := Obj.ReadUShort()
    ScoutsTable := ReadUChar(Obj, Len)
    Data.Push(['Scouts Table', ScoutsTable])

    ; Update
    RowsCount := Titles.GetCount()
    For Index, Title in Data {
        If Index > RowsCount {
            Titles.Add(, Title[1])
        } Else {
            currTitle := Titles.GetText(Index)
            If currTitle != Title[1] {
                Titles.Modify(Index,, Title[1])
            }
        }
    }

    ReadUChar(Obj, Len := 1) {
        Str := ''
        Loop Len
            Str .= Chr(Obj.ReadUChar())
        Return Str
    }
}

#HotIf WinActive('Room ahk_exe GameRanger.exe') || WinActive('Message ahk_exe GameRanger.exe') || WinActive('ahk_exe age2_x1.exe')
^!v:: {
    SendInput('Send Macro Begin at ' FormatTime(A_Now, 'yyyy/dd/mm HH:mm:ss'))
    Sleep 50
        SendInput('`n`n')
    Sleep 50
    For Index, Title in Data {
        Text1 := StrReplace(Title[1], '¡')
        Text2 := StrReplace(Title[2], '¡')
        SendInput('[[ ' Text1 ' ]]')
        Sleep 50
        SendInput('`n-')
        Sleep 50
        SendInput('`n')
        Sleep 50
        SendInput(Text2)
        Sleep 50
        SendInput('`n-')
        Sleep 50
        SendInput('`n')
        Sleep 50
    }
    SendInput('Send Macro End at ' FormatTime(A_Now, 'yyyy/dd/mm HH:mm:ss'))
    Sleep 50
        SendInput('`n`n')
    Sleep 50
}
^!z:: {
    If Row := Titles.GetNext() {
        SendInput('Send Macro Begin at ' FormatTime(A_Now, 'yyyy/dd/mm HH:mm:ss'))
        Sleep 50
            SendInput('`n`n')
        Sleep 50
        Text1 := StrReplace(Data[Row][1], '¡')
        Text2 := StrReplace(Data[Row][2], '¡')
        SendInput('[[ ' Text1 ' ]]')
        Sleep 50
        SendInput('`n-')
        Sleep 50
        SendInput('`n')
        Sleep 50
        SendInput(Text2)
        Sleep 50
        SendInput('`n-')
        Sleep 50
        SendInput('`n')
        Sleep 50
        SendInput('Send Macro End at ' FormatTime(A_Now, 'yyyy/dd/mm HH:mm:ss'))
        Sleep 50
            SendInput('`n`n')
        Sleep 50
    }
}
#HotIf