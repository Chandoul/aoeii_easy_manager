#Requires AutoHotkey v2
#SingleInstance Force

#Include <ReadWriteJSON>

GRApp := ReadSetting(, 'GRApp')
HAI := ReadSetting(, 'HAI')
Possibilities := HAI['Possibilities']
VPNPath := (A_Is64bitOS ? EnvGet('ProgramFiles(x86)') : EnvGet('ProgramFiles')) HAI['VPNPath']
SetRegView(A_Is64bitOS ? 64 : 32)
Layers := HAI['Layers']

AoEIIAIO := Gui(, 'HIDE ALL IP TRIAL RESET')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')

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