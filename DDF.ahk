#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ValidGame>
#Include <ReadWriteJSON>
#Include <ImageButton>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
DDF := 'DB\Base\cnc-ddraw.2'

AoEIIAIO := Gui(, 'DIRECT DRAW FIX')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')

SetRegView(A_Is64bitOS ? 64 : 32)

AoEIIAIO.SetFont('s16')
H := AoEIIAIO.AddButton('w392', !FileExist(GameDirectory '\ddraw.dll') ? 'Apply the direct draw fix' : 'Remove the direct draw fix')
H.SetFont('s12 Bold', 'Calibri')
H.OnEvent('Click', DDFIX)

AoEIIAIO.AddPicture('', 'DB\Base\aok.png')
EHA := AoEIIAIO.AddButton('yp w350 h32' (!FileExist(GameDirectory '\ddraw.dll') ? ' Disabled' : ''), 'Age of Empires II Direct Draw Options')
EHA.SetFont('s10 Bold', 'Calibri')
EHA.OnEvent('Click', EDITDDFIXA)

AoEIIAIO.AddPicture('xm', 'DB\Base\aoc.png')
EHC := AoEIIAIO.AddButton('yp w350 h32' (!FileExist(GameDirectory '\ddraw.dll') ? ' Disabled' : ''), 'The Conquerors Direct Draw Options')
EHC.SetFont('s10 Bold', 'Calibri')
EHC.OnEvent('Click', EDITDDFIXC)

DDFIX(Ctrl, Info) {
	Command := StrSplit(Ctrl.Text, ' ')[1]
	Switch Command {
		Case 'Apply':
			DirCopy(DDF, GameDirectory, 1)
			DirCopy(DDF, GameDirectory '\age2_x1', 1)

			IniWrite('false', GameDirectory '\ddraw.ini', 'ddraw',  'fullscreen')
			IniWrite('false', GameDirectory '\ddraw.ini', 'ddraw',  'border')
			IniWrite('true'	, GameDirectory '\ddraw.ini', 'ddraw',  'windowed')
			IniWrite('true'	, GameDirectory '\ddraw.ini', 'ddraw',  'devmode')
			IniWrite('0'	, GameDirectory '\ddraw.ini', 'ddraw',  'hook')

			IniWrite('false', GameDirectory '\age2_x1\ddraw.ini', 'ddraw',  'fullscreen')
			IniWrite('false', GameDirectory '\age2_x1\ddraw.ini', 'ddraw',  'border')
			IniWrite('true'	, GameDirectory '\age2_x1\ddraw.ini', 'ddraw',  'windowed')
			IniWrite('true'	, GameDirectory '\age2_x1\ddraw.ini', 'ddraw',  'devmode')
			IniWrite('0'	, GameDirectory '\age2_x1\ddraw.ini', 'ddraw',  'hook')

			Ctrl.Text := 'Remove the direct draw fix'
			EHA.Enabled := True
			EHC.Enabled := True
		Case 'Remove':
			Loop Files, DDF "\*.*", 'R' {
				FilePath := StrReplace(A_LoopFileFullPath, A_ScriptDir '\')
				FilePath := StrReplace(FilePath, DDF '\')
				If FileExist(GameDirectory '\' FilePath)
					FileDelete(GameDirectory '\' FilePath)
				If FileExist(GameDirectory '\age2_x1\' FilePath)
					FileDelete(GameDirectory '\age2_x1\' FilePath)
			}
			Ctrl.Text := 'Apply the direct draw fix'
			EHA.Enabled := False
			EHC.Enabled := False
	}
	If A_Args.Length
		SetTimer(Quit, -1000)
	Msgbox('Complete!', 'DIRECT DRAW', 0x40)
}

EDITDDFIXA(Ctrl, Info) {
	If FileExist(GameDirectory '\cnc-ddraw config.exe') {
		RunWait(GameDirectory '\cnc-ddraw config.exe')
	}
}

EDITDDFIXC(Ctrl, Info) {
	If FileExist(GameDirectory '\age2_x1\cnc-ddraw config.exe') {
		RunWait(GameDirectory '\age2_x1\cnc-ddraw config.exe')
	}
}

AoEIIAIO.Show()
If !ValidGameDirectory(GameDirectory) {
	If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
		Run('Game.ahk')
	}
	ExitApp()
}

If A_Args.Length {
	Switch A_Args[1] {
		Case 'Apply':
			H.Text := 'Apply the direct draw fix'
			DDFIX(H, '')
			
	}
}


Quit() {
	ExitApp()
}