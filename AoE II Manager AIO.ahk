#Requires AutoHotkey v2
#SingleInstance Force

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

BasePackage := ReadSetting(, 'BasePackage')

Try DownloadPackages(BasePackage), ExtractPackage(BasePackage[2], 'DB\000',, 1)
Catch {
    MsgBox('Sorry!, something went wrong!', 'Error', 0x30)
    ExitApp()
}

Features := Map()
Features['Main'] := []
AppName := ReadSetting(, 'AppName')
Version := ReadSetting(, 'Version')

AoEIIAIO := Gui(, 'Age of Empires II Easy Manager!')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Segoe UI')

WD := AoEIIAIO.AddButton('x0 y0', '...')
AoEIIAIO.SetFont('Bold s15')
T := AoEIIAIO.AddText('xm cGreen Center', AppName ' v' Version)
P := AoEIIAIO.AddPicture('xm+90', 'DB\000\game.png')
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

}

AoEIIAIO.SetFont('Bold s10')
H := AoEIIAIO.AddButton('xm w150', 'My Game')
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

H := AoEIIAIO.AddButton('xm wp', 'Hide All IP')
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

AoEIIAIO.Show()

R.Redraw()
AoEIIAIO.GetPos(,, &W, &H)
R.GetPos(, &Y)
U.GetPos(,, &WU)
U.Move(W - WU - 25, Y)
U.Redraw()
T.Move(0,, W)
T.Redraw()
P.Move((W - 373) / 2)
WD.Move(,, W - 16)
WD.SetFont('Bold s10', 'Segoe UI')
WD.OnEvent('Click', (*) => OpenGameFolder())
OpenGameFolder() {
    GameDirectory := ReadSetting('Setting.json', 'GameLocation')
    If ValidGameDirectory(GameDirectory) {
        Run(GameDirectory '\')
    }
}

GameDirectory := ReadSetting('Setting.json', 'GameLocation')
If !ValidGameDirectory(GameDirectory) {
    P.Value := 'DB\000\gameoff.png'
    For Each, Version in Features['Main'] {
        Version.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    Return
}
WD.Text := 'Current selection: "' GameDirectory '"'
CreateImageButton(WD, 0, IBGray*)