#Include SharedLib.ahk
AoEIIAIO.Title := 'HIDE ALL IP TRIAL RESET'
Possibilities := [
    'CLEAR'
  , 'WIN8RTM'
  , 'WIN7RTM'
  , 'RUNASADMIN'
  , 'WIN8RTM RUNASADMIN'
  , 'WIN7RTM RUNASADMIN'
]
If A_Is64bitOS {
    VPNPath := EnvGet('ProgramFiles(x86)') '\Hide ALL IP\HideALLIP.exe'
    SetRegView(64)
} Else {
    VPNPath := EnvGet('ProgramFiles') '\Hide ALL IP\HideALLIP.exe'
    SetRegView(32)
}
AoEIIAIO.SetFont('s16')
H := AoEIIAIO.AddButton(, 'Hide All IP Trial Reset [ Attempt ' (Index := 1) ' / ' Possibilities.Length ' ]')
H.SetFont('s10 Bold', 'Calibri')
H.OnEvent('Click', ResetProcess)
ResetProcess(Ctrl, Info) {
    Try {
        Global Index
        If RegRead(Layers, GRApp, '')
            RegDelete(Layers, GRApp)
        If RegRead(Layers, VPNPath, '')
            RegDelete(Layers, VPNPath)
        Log := ''
        Switch Possibilities[Index] {
            Case 'CLEAR' :
                Loop Parse, "HKCU|HKLM", '|' {
                    HK := A_LoopField
                    Loop Parse, "Software\HideAllIP|Software\Wow6432Node\HideAllIP", '|' {
                        Loop Reg, HK "\" A_LoopField {
                            RegDeleteKey(A_LoopRegkey)
                        }
                    }
                }
                Log := 'Cleared registery'
            Default :
                RegWrite(Possibilities[Index], 'REG_SZ', Layers, VPNPath)
                Log := 'Set compatibility = ' Possibilities[Index] ''
        }
        MsgBox('Attempt ' Index ' / ' Possibilities.Length  '`n`n' Log, 'OK', 0x40 ' T5')
        If ProcessExist('HideALLIP.exe') {
            ProcessClose('HideALLIP.exe')
        }
		If !FileExist(VPNPath) {
			Msgbox('You must install Hide All IP!', 'Unable to run', 0x30)
			Return
		}
        Run(VPNPath)
        ; Update attempts
        If ++Index > Possibilities.Length {
            Index := 1
        }
        H.Text := 'Hide All IP Trial Reset [ Attempt ' Index ' / ' Possibilities.Length ' ]'
    } Catch Error As Err {
        MsgBox("Reset failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
AoEIIAIO.Show()