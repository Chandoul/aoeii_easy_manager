#Requires AutoHotkey v2
#SingleInstance Force

DrsBuild := 'DB\000\DrsBuild.exe'
Files := FileSelect('M',,, "Drs File(*.slp;*.wav;*.bina)")
If !Output := InputBox(,, 'h100', 'gamedata_x1_p1.drs')
    ExitApp()
For FileN in Files {
    SplitPath(FileN, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt)
    If !InStr(OutFileName, 'gam') {
        FileMove(FileN, OutDir '\gam' Format('{:05}', OutNameNoExt) '.' OutExtension)
    }
    ToolTip(A_Index ' / ' Files.Length)
}
RunWait(A_ComSpec ' /k ' DrsBuild ' /a ' Output.Value ' "' OutDir '\*.slp" "' OutDir '\*.wav"')