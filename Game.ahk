#Requires AutoHotkey v2
#SingleInstance Force
#Include <InitGame>
#Include <ImageButton>
#Include <ValidGame>
#Include <GetConnectedState>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <FolderGetSize>
AoEIIAIO := Gui(, 'GAME LOCATION')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')
Select := AoEIIAIO.AddButton('xm w200 h27', 'Select')
Select.OnEvent('Click', SelectDirectory)
CreateImageButton(Select, 0, [['DB\000\pick_folder_normal.png'], ['DB\000\pick_folder_hover.png'], ['DB\000\pick_folder_click.png'], ['DB\000\pick_folder_disable.png',, 0xCCCCCC]]*)
H := AoEIIAIO.AddButton('w200 yp', 'Open the selected')
H.OnEvent('Click', (*) => GameDirectory.Value ? Run(GameDirectory.Value '\') : 0)
CreateImageButton(H, 0, [['DB\000\open_aoeii_normal.png'], ['DB\000\open_aoeii_hover.png'], ['DB\000\open_aoeii_click.png'], ['DB\000\open_aoeii_disable.png',, 0xCCCCCC]]*)
GameDirectory := AoEIIAIO.AddEdit('cRed xm ReadOnly w410 -E0x200 Border BackgroundWhite Center')
SelectGR := AoEIIAIO.AddButton('xm w200', 'Select from GameRanger')
CreateImageButton(SelectGR, 0, [['DB\000\gr_get_normal.png'], ['DB\000\gr_get_hover.png'], ['DB\000\gr_get_click.png'], ['DB\000\gr_get_disable.png',, 0xCCCCCC]]*)
SelectGR.OnEvent('Click', SelectDirectoryGR)
H := AoEIIAIO.AddButton('w200 yp', 'Set into GameRanger')
CreateImageButton(H, 0, [['DB\000\gr_get_normal.png'], ['DB\000\gr_get_hover.png'], ['DB\000\gr_get_click.png'], ['DB\000\gr_get_disable.png',, 0xCCCCCC]]*)
H.OnEvent('Click', SetDirectoryGR)
H := AoEIIAIO.AddButton('xm w410', 'Download the game')
H.OnEvent('Click', DownloadGame)
CreateImageButton(H, 0, [['DB\000\download_aoeii_normal.png'], ['DB\000\download_aoeii_hover.png'], ['DB\000\download_aoeii_click.png'], ['DB\000\download_aoeii_disable.png',, 0xCCCCCC]]*)
H := AoEIIAIO.AddButton('xm w410', 'Delete the game')
H.OnEvent('Click', DeleteGame)
CreateImageButton(H, 0, [['DB\000\delete_aoeii_normal.png',, 0xFF0000], ['DB\000\delete_aoeii_hover.png',, 0xFF0000], ['DB\000\delete_aoeii_click.png',, 0xFF0000], ['DB\000\delete_aoeii_disable.png',, 0xCCCCCC]]*)
DeskShort := AoEIIAIO.AddCheckbox(, 'Notify to add the game desktop shortcuts')
DeskShort.OnEvent('Click', GameShortcuts)
PBT := AoEIIAIO.AddText('Center w410 Hidden cBlue')
PB := AoEIIAIO.AddProgress('-Smooth wp Hidden')
AoEIIAIO.Show()

; Load settings
FGameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(FGameDirectory) {
    SelectDirectoryGR(SelectGR, '')
}
FGameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(FGameDirectory) {
    SelectDirectory(Select, '')
}
FGameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(FGameDirectory) {
    Return
}
GameDirectory.Value := FGameDirectory
If IniRead(Config, 'Settings', 'Shortcut', 0) {
    DeskShort.Value := 1
    AddGameShortcuts()
    Return
}
; Adds game shortcuts
GameShortcuts(Ctrl, Info) {
    IniWrite(Ctrl.Value, Config, 'Settings', 'Shortcut')
    If Ctrl.Value {
        AddGameShortcuts()
    }
}
; Sets a location into GR
SetDirectoryGR(Ctrl, Info) {
    Ctrl.Enabled := False
    If !ValidGameDirectory(GameDirectory.Value) {
        If 'Yes' != MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
            Ctrl.Enabled := True
            Return
        }
        SelectDirectory(Select, '')
    }
    If !ProcessExist('GameRanger.exe') {
        MsgBox('Make sure GameRanger is running!', 'Invalid', 0x30)
        Ctrl.Enabled := True
        Return
    }
    ; Select macro
    MacroSelect(Game, Row) {
        If !FileExist(GameDirectory.Value '\' Game) {
            Ctrl.Enabled := True
            Return False
        }
        Run(GRApp)
        WinActivate('ahk_exe GameRanger.exe')
        If !WinWaitActive('ahk_exe GameRanger.exe',, 5) {
            MsgBox('Unable to get the GameRanger window!', 'Invalid', 0x30)
            Ctrl.Enabled := True
            Return False
        }
        Sleep(500)
        SendInput('^e')
        Sleep(500)
        If !WinWaitActive('Options ahk_exe GameRanger.exe',, 5) {
            MsgBox('Unable to get the GameRanger option window!', 'Invalid', 0x30)
            Ctrl.Enabled := True
            Return False
        }
        ControlChooseIndex(1, 'SysTabControl321', 'Options ahk_exe GameRanger.exe')
        ControlFocus('SysListView321', 'Options ahk_exe GameRanger.exe')
        SendInput('{Home}')
        SendInput('{Down ' Row '}')
        WinGetPos(&X, &Y, &W, &H, 'Options ahk_exe GameRanger.exe')
        MouseClick('Left', W - 115, H - 65)
        If !WinWaitActive('Choose ahk_exe GameRanger.exe',, 5) {
            MsgBox('Unable to get the GameRanger selection window!', 'Invalid', 0x30)
            Ctrl.Enabled := True
            Return False
        }
        ControlSetText(GameDirectory.Value '\' Game, 'Edit1', 'Choose ahk_exe GameRanger.exe')
        WinGetPos(&X, &Y, &W, &H, 'Choose ahk_exe GameRanger.exe')
        MouseClick('Left', W - 50, H - 120)
        WinClose('Options ahk_exe GameRanger.exe')
        Return True
    }
    If !MacroSelect('empires2.exe', 12) 
    || !MacroSelect('age2_x1\age2_x1.exe', 14) 
    || !MacroSelect('age2_x1\age2_x2.exe', 11) {
        MsgBox('No game was found!', 'Invalid', 0x30)
        Ctrl.Enabled := True
        Return False
    }
    MsgBox('Game selected successfully!`n`nNow GameRanger must restart to unlock the game excutables`nRestarting in 5 seconds...', 'Game select', 0x40 ' T5')
    ProcessClose('GameRanger.exe')
    Run(GRApp)
    Ctrl.Enabled := True
}
; Selects a location from GR
SelectDirectoryGR(Ctrl, Info) {
    Try {
        Ctrl.Enabled := False
        Text := BinGrabText(GRSetting)
        Locations := TextGrabPath(Text, ['empires2.exe', 'age2_x1.exe', 'age2_x2.exe'])
        For Location in Locations {
            If RC := ValidGameDirectory(Location) {
                Choice := MsgBox('Want to select this location?`n`n' Location, 'Game Location', 0x4 + 0x40)
                If Choice = 'Yes' {
                    GameDirectory.Value := Location
                    IniWrite(Location, Config, 'Settings', 'GameDirectory')
                    IniWrite(1, Config, 'SelectionHistory', Location)
                    AddGameShortcuts()
                    Break
                }
            }
        }
    } Catch Error As Err {
        MsgBox("Select failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
        Ctrl.Enabled := True
    }
    Ctrl.Enabled := True
}
; Selects a location
SelectDirectory(Ctrl, Info) {
    Ctrl.Enabled := False
    If SelectedDirectory := FileSelect('D', 'C:\' (A_Is64bitOS ? 'Program Files (x86)' : 'Program Files') '\Microsoft Games') {
        If !Valid := ValidGameDirectory(SelectedDirectory) {
            SelectedDirectoryEx := SelectedDirectory
            SelectedDirectory := ''
            SplitPath(SelectedDirectoryEx, &_, &ParentSelectedDirectory)
            If Valid := ValidGameDirectory(ParentSelectedDirectory) {
                Choice := MsgBox('Want to select this location?`n`n' ParentSelectedDirectory, 'Game Location', 0x4 + 0x40)
                If Choice = 'Yes' {
                    SelectedDirectory := ParentSelectedDirectory
                }
            }
        }
        If !Valid {
            Loop Files, SelectedDirectoryEx '\*', 'D' {
                If ValidGameDirectory(A_LoopFileFullPath) {
                    Choice := MsgBox('Want to select this location?`n`n' A_LoopFileFullPath, 'Game Location', 0x4 + 0x40)
                    If Choice = 'Yes' {
                        SelectedDirectory := A_LoopFileFullPath
                        Break
                    }
                }
            }
        }
        If SelectedDirectory != '' {
            GameDirectory.Value := StrUpper(SelectedDirectory)
            IniWrite(SelectedDirectory, Config, 'Settings', 'GameDirectory')
            IniWrite(1, Config, 'SelectionHistory', SelectedDirectory)
            AddGameShortcuts()
        } Else {
            MsgBox('Nothing was selected!', 'Game location', 0x30)
        }
    }
    Ctrl.Enabled := True
}
; Deletes the game
DeleteGame(Ctrl, Info) {
    Ctrl.Enabled := False
    Try {
        Run('UninstallGame.ahk')
    } Catch Error As Err {
        MsgBox("Run failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
        Ctrl.Enabled := True
    }
    Ctrl.Enabled := True
}
; Downloads and installs the game
DownloadGame(Ctrl, Info) {
    Try {
        If !GetConnectedState() {
            MsgBox('Make sure you are connected to the internet!', "Can't download!", 0x30)
            Return
        }
        If (SGameDirectory := FileSelect('D',, 'Game install location')) && 'Yes' = MsgBox('Are you sure want to install at this location?`n' SGameDirectory, 'Game install location', 0x40 + 0x4) {
            SGameDirectory := RegExReplace(SGameDirectory, "\\$")
            SGameDirectory := SGameDirectory '\Age of Empires II'
            If !DirExist(SGameDirectory) {
                DirCreate(SGameDirectory)
            }
            If ValidGameDirectory(SGameDirectory) && 'Yes' != MsgBox('It seems like the game already installed at this location!`nWant continue?', 'Game location install', 0x30 + 0x4) {
                Return
            }
            ; Check for packages updates
            Ctrl.Enabled := False
            PB.Value := 0
            PB.Opt('Range0-' GamePackages.Length + 3)
            PB.Visible := True
            PBT.Visible := True
            For Package in GamePackages {
                File := StrReplace(Package, 'https://raw.githubusercontent.com/SmileAoE/aoeii_aio/main/', '')
                File := StrReplace(File, '/', '\')
                PBT.Value := 'Downloading ' File
                DownloadPackage(Package, File)
                PB.Value += 1
            }
            ; AOK extract
            PBT.Value := 'Exporting The Age of Kings'
            ExtractPackage('DB\003.7z.001', SGameDirectory)
            PB.Value += 1
            ; AOC extract
            PBT.Value := 'Exporting The Conquerors'
            ExtractPackage('DB\004.7z.001', SGameDirectory)
            PB.Value += 1
            ; FE extract
            PBT.Value := 'Exporting Forgotten Empires'
            ExtractPackage('DB\005.7z.001', SGameDirectory)
            PB.Value += 1
            ; Add the reg keys
            UpdateGameReg(SGameDirectory)
            If 'Yes' = MsgBox('Game installation complete!`nWanna select this game?', 'Game install location', 0x4 + 0x40) {
                GameDirectory.Value := StrUpper(SGameDirectory)
                IniWrite(SGameDirectory, Config, 'Settings', 'GameDirectory')
                IniWrite(1, Config, 'SelectionHistory', SGameDirectory)
                AddGameShortcuts()
            }
        }
        PB.Visible := False
        PBT.Visible := False
        Ctrl.Enabled := True
    } Catch Error As Err {
        MsgBox("Download failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
        PB.Visible := False
        PBT.Visible := False
        Ctrl.Enabled := True
    }
}
; Updates game install registery settings
UpdateGameReg(GameDirectory) {
    RegWrite('Age of Empires II AIO', 'REG_SZ', InstallRegKey, 'DisplayName')
    RegWrite('AOK (2.0) / AOC (1.0) / FE (2.1)', 'REG_SZ', InstallRegKey, 'DisplayVersion')
    RegWrite(GameDirectory '\age2_x1\age2_x1.exe', 'REG_SZ', InstallRegKey, 'DisplayIcon')
    RegWrite(GameDirectory, 'REG_SZ', InstallRegKey, 'InstallLocation')
    RegWrite(1, 'REG_DWORD', InstallRegKey, 'NoModify')
    RegWrite(1, 'REG_DWORD', InstallRegKey, 'NoRepair')
    RegWrite(FolderGetSize(GameDirectory), 'REG_DWORD', InstallRegKey, 'EstimatedSize')
    RegWrite('Microsoft Corporation', 'REG_SZ', InstallRegKey, 'Publisher')
    RegWrite('"' A_AhkPath '" "' A_ScriptDir '\UninstallGame.ahk" "' GameDirectory '"', 'REG_SZ', InstallRegKey, 'UninstallString')
}
; Grabs the readable text from binary file
BinGrabText(Filepath) {
    Text := ''
    BufferObj := FileRead(Filepath, 'RAW')
    Loop BufferObj.Size {
        Address := A_Index - 1
        Byte := NumGet(BufferObj, Address, 'UChar')
        If (C := Chr(Byte)) != '' {
            Text .= C
        }
    }
    Return Text
}
; Parses the game locations out of a text
TextGrabPath(TextFound, Excutables) {
    ResultMap := Map()
    For Each, Excutable in Excutables {
        P := InStr(TextFound, LFE := Excutable,, -1)
        Loop {
            Char := SubStr(TextFound, P - (I := A_Index), 1)
            LFE := Char LFE
        } Until (Char = ':' || Ord(Char) = 10 || Ord(Char) = 13)
        FoundPath := SubStr(TextFound, P - (I + 1), 1) LFE
        FoundPath := StrReplace(FoundPath, '\' Excutables[1])
        FoundPath := StrReplace(FoundPath, '\age2_x1\' Excutables[2])
        FoundPath := StrReplace(FoundPath, '\age2_x1\' Excutables[3])
        ResultMap[StrUpper(FoundPath)] := True
    }
    Return ResultMap
}
; Adds game shortcuts to the desktop
AddGameShortcuts() {
    Try {
        GameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
        AddShortcut := IniRead(Config, 'Settings', 'Shortcut', 0)
        If AddShortcut && ValidGameDirectory(GameDirectory) {
            CreateShortcut := False
            If FileExist(GameDirectory '\empires2.exe') {
                If !FileExist(A_Desktop '\The Age of Kings.lnk') {
                    CreateShortcut := True
                } Else {
                    FileGetShortcut(A_Desktop '\The Age of Kings.lnk', &OutTarget)
                    If OutTarget != GameDirectory '\empires2.exe' {
                        CreateShortcut := True
                    } Else {
                        CreateShortcut := False
                    }
                }
            }
            If FileExist(GameDirectory '\age2_x1\age2_x1.exe') && !CreateShortcut {
                If !FileExist(A_Desktop '\The Conquerors.lnk') {
                    CreateShortcut := True
                } Else {
                    FileGetShortcut(A_Desktop '\The Conquerors.lnk', &OutTarget)
                    If OutTarget != GameDirectory '\age2_x1\age2_x1.exe' {
                        CreateShortcut := True
                    } Else {
                        CreateShortcut := False
                    }
                }
            }
            If FileExist(GameDirectory '\age2_x1\age2_x2.exe') && !CreateShortcut {
                If !FileExist(A_Desktop '\Forgotten Empires.lnk') {
                    CreateShortcut := True
                } Else {
                    FileGetShortcut(A_Desktop '\Forgotten Empires.lnk', &OutTarget)
                    If OutTarget != GameDirectory '\age2_x1\age2_x2.exe' {
                        CreateShortcut := True
                    } Else {
                        CreateShortcut := False
                    }
                }
            }
            If CreateShortcut {
                If 'Yes' = MsgBox('Want to create the game desktop shortcuts?', 'Game', 0x4 + 0x40) {
                    FileCreateShortcut(GameDirectory '\empires2.exe', A_Desktop '\The Age of Kings.lnk', GameDirectory)
                    FileCreateShortcut(GameDirectory '\age2_x1\age2_x1.exe', A_Desktop '\The Conquerors.lnk', GameDirectory '\age2_x1')
                    FileCreateShortcut(GameDirectory '\age2_x1\age2_x2.exe', A_Desktop '\Forgotten Empires.lnk', GameDirectory '\age2_x1')
                }
            }
        }
    } Catch Error As Err {
        MsgBox("Add shortcut failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
    }
}