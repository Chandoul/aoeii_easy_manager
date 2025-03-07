#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>

If !A_IsAdmin {
    MsgBox('Script must run as administrator!', 'Warn', 0x30)
    ExitApp
}

#Include <ImageButton>
#Include <IBButtons>
#Include <ValidGame>
#Include <ReadWriteJSON>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <WatchFileSize>

Features := Map()
Features['Main'] := []
AppName := ReadSetting(, 'AppName')
Version := ReadSetting(, 'Version')
Latest := ReadSetting(, 'Latest')

AoEIIAIO := Gui(, 'Age of Empires II Easy Manager!')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Segoe UI')

;AoEIIAIO.AddPicture('x0 y0', 'DB\Base\Back.png')

CreateImageButton("SetDefGuiColor", '0x030303')

WD := AoEIIAIO.AddButton('x0 y0', '...')
AoEIIAIO.SetFont('Bold s18')
T := AoEIIAIO.AddText('xm cGreen Center BackgroundTrans y40', AppName ' v' Version)
P := AoEIIAIO.AddPicture('xm+90 y80', 'DB\Base\game.png')
AoEIIAIO.SetFont('Bold s12')

R := AoEIIAIO.AddButton('xm ym+30 w100', 'Reload')
R.SetFont('Bold s10')
CreateImageButton(R, 0, IBRed*)
R.OnEvent('Click', (*) => Reload())

U := AoEIIAIO.AddButton('w100', 'Update')
U.SetFont('Bold s10')
CreateImageButton(U, 0, IBBlue*)
U.OnEvent('Click', Check4Updates)
Check4Updates(Ctrl, Info) {
    Try {
        Download(Latest[1], A_Temp '\AoE II Manager.json')
        LVersion := ReadSetting(A_Temp '\AoE II Manager.json', 'Version', '')
        If !IsNumber(LVersion) {
            MsgBox('Unable to check updates!, please make sure you are well connected to the internet before you update.', 'Update check error!', 0x30)
            Return
        }
        If LVersion > Version {
            If 'Yes' != MsgBox('New update was found! version = ' LVersion '`nDownload the new update?', 'Update', 0x4 + 0x40) {
                Return
            }
            SetTimer(WatchFileSize.Bind(A_Temp '\AoE II Manager AIO.exe', Ctrl), 1000)
            Download(Latest[2], A_Temp '\AoE II Manager AIO.exe')
            SetTimer(WatchFileSize, 0)
            Run(A_Temp '\AoE II Manager AIO.exe')
            ExitApp()
        }
        MsgBox('You got the latest update!', 'Update', 0x40)
    } Catch {
        MsgBox('Unable to check updates!, please make sure you are well connected to the internet before you update.', 'Update check error!', 0x30)
    }
}

AoEIIAIO.SetFont('Bold s10')
H := AoEIIAIO.AddButton('xm y310 w150', 'My Game')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchGame)
LaunchGame(Ctrl, Info) {
    Try Run('Game.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Game', 0x10)
}

H := AoEIIAIO.AddButton('yp wp', 'Version')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchVersion)
Features['Main'].Push(H)
LaunchVersion(Ctrl, Info) {
    Try Run('Version.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Patch/Fix')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchFixes)
Features['Main'].Push(H)
LaunchFixes(Ctrl, Info) {
    Try Run('Fixs.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Language')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchLanguage)
Features['Main'].Push(H)
LaunchLanguage(Ctrl, Info) {
    Try Run('Language.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Language', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Visual Mods')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchVM)
Features['Main'].Push(H)
LaunchVM(Ctrl, Info) {
    Try Run('VM.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Visual Mod', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Data Mods')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchDM)
Features['Main'].Push(H)
LaunchDM(Ctrl, Info) {
    Try Run('DM.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Data Mod', 0x10)

}

H := AoEIIAIO.AddButton('xm y350 wp', 'Hide All IP')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchVPN)
Features['Main'].Push(H)
LaunchVPN(Ctrl, Info) {
    Try Run('VPN.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'VPN', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Shortcuts')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchAHK)
Features['Main'].Push(H)
LaunchAHK(Ctrl, Info) {
    Try Run('AHK.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'AutoHotkey', 0x10)

}

H := AoEIIAIO.AddButton('yp wp', 'Direct Draw Fix')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchDDF)
Features['Main'].Push(H)
LaunchDDF(Ctrl, Info) {
    Try Run('DDF.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'DirectDraw', 0x10)

}

H := AoEIIAIO.AddButton('yp wp+160', 'GameRanger Account Switcher')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchGRAS)
Features['Main'].Push(H)
LaunchGRAS(Ctrl, Info) {
    Try Run('GRAS.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'DirectDraw', 0x10)

}

H := AoEIIAIO.AddButton('yp w150', 'Scenarios')
CreateImageButton(H, 0, IBBlack*)
H.OnEvent('Click', LaunchRPG)
Features['Main'].Push(H)
LaunchRPG(Ctrl, Info) {
    Try Run('Scx.ahk')
    Catch Error As Err
        MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'DirectDraw', 0x10)

}
AoEIIAIO.Show()
R.Redraw()
AoEIIAIO.GetPos(,, &W, &H)
R.GetPos(, &Y)
U.GetPos(,, &WU)
U.Move(W - WU - 25, Y)
U.Redraw()
T.Move(0,, W)
T.Redraw()
P.Move((W - 510) / 2)
P.Redraw()
WD.Move(,, W - 16)
WD.SetFont('Bold s10', 'Segoe UI')
CreateImageButton(WD, 0, IBGray*)
WD.OnEvent('Click', (*) => OpenGameFolder())
OpenGameFolder() {
    GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
    If ValidGameDirectory(GameDirectory) {
        Run(GameDirectory '\')
    } Else MsgBox('You must select your game folder!', 'Info', 0x30)
}
GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
If !ValidGameDirectory(GameDirectory) {
    P.Value := 'DB\Base\gameoff.png'
    For Each, Version in Features['Main'] {
        Switch Version.Text {
            Case "Hide All IP"
               , "GameRanger Account Switcher"
               , "Shortcuts": Continue
            Default: Version.Enabled := False
        }
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    Return
}
WD.Text := 'Current selection: "' GameDirectory '"'
CreateImageButton(WD, 0, IBGray*)

#HotIf WinActive(AoEIIAIO)
^!u:: {
    If MsgBox('Are sure to continue?, make sure you know what you doing before you continue', 'Confirm', 0x30 + 0x4) != 'Yes'
        Return
    FileCopy('DB\Base\ubh', GameDirectory '\dsound.dll', 1)
    FileCopy('DB\Base\ubh', GameDirectory '\age2_x1\dsound.dll', 1)
}
#HotIf