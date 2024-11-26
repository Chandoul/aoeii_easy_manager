#Requires AutoHotkey v2
#SingleInstance Force

#Include <ValidGame>
#Include <ReadWriteJSON>

GameDirectory := ReadSetting('Setting.json', 'GameLocation')

AoEIIAIO := Gui(, 'DIRECT DRAW FIX')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')

SetRegView(A_Is64bitOS ? 64 : 32)

AoEIIAIO.SetFont('s16')
H := AoEIIAIO.AddButton('w300', 'Apply the fix')
H.SetFont('s10 Bold', 'Calibri')
H.OnEvent('Click', DDFIX)
DDFIX(Ctrl, Info) {
	Loop Parse, "HKCU|HKLM|HKU", '|' {
		HK := A_LoopField
		Loop Parse, "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store"
				  . "|S-1-5-21-2643294048-3836381920-2045673291-1001\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store", '|' {
			Loop Reg, HK "\" A_LoopField, 'R' {
				If A_LoopRegName = GameDirectory '\empires2.exe'
				|| A_LoopRegName = GameDirectory '\age2_x1\age2_x1.exe' {
					RegWrite('', 'REG_BINARY', A_LoopRegkey, A_LoopRegName)
				}
			}
		}
	}
	Msgbox('Complete!', 'DIRECT DRAW', 0x40)
}
AoEIIAIO.Show()
If !ValidGameDirectory(GameDirectory) {
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}