#Requires AutoHotkey v2
#SingleInstance Force
APP := 'https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/refs/heads/main/data/Base.7z'
EXE := '7zr.exe'
If !DirExist('app') {
	Try {
		Download(APP, 'Base.7z')
		Download('https://www.7-zip.org/a/7zr.exe', EXE)
		buf := FileRead('7zr.exe', "RAW")
		If StrGet(buf, 2, "cp0") !== "MZ" {
			Msgbox("7zr doesn't seem to be a valid executable!",, 0x30)
			buf := ''
			ExitApp
		}
		buf := ''
		RET := RunWait(EXE ' x Base.7z -aoa',, 'Hide')
	} Catch As Err {
		Msgbox(Err.What, 'Error occured', 0x30)
		ExitApp
	}
}
AOE_II := 'https://media.githubusercontent.com/media/Chandoul/aoeii_easy_manager/refs/heads/main/data/Age%20of%20Empires%20II.7z?download=true'
Game := Gui(, 'Age of Empires II Setup')
Game.OnEvent('Close', (*) => Quit())
Quit() {
	If ProcessExist('7za.exe') {
		ProcessClose('7za.exe')
	}
	ExitApp()
}
Game.MarginX := 10
Game.MarginY := 10
Game.AddTab3('w800 h600', ['Game', 'Patchs/Versions'])
Gameoff := Game.AddPicture('xm+218 ym+50', 'app\gameoff.png')
Game.SetFont('s10', 'Segoe UI')
GameLocation := Game.AddComboBox('w363 Center ReadOnly cBlue')
GameLocation.OnEvent('Change', (*) => SelectGame(GameLocation.Text))
AllGameLocation := LoadGameLocation()
LoadGameLocation() {
	L := Map()
	If FileExist('GameLocation') {
		Loop Read, 'GameLocation' {
			Location := A_LoopReadLine
			S := InStr(Location, '>')
			If !L.Has(Location) && IsValidSelection(&Location) {
				GameLocation.Add([Location])
				L[Location] := 0
				If S {
					GameLocation.Choose(Location)
					L[Location] := 1
					Gameoff.Value := 'app\game.png'
				}
			}
		}
	}
	Return L
}
Game.SetFont('s14 Bold')
GameCreateBtn := Game.AddButton('w363', 'Create New')
UseGDIP()
CreateImageButton(GameCreateBtn, 0, [['0xFF1F883D',, '0xFFFFFFFF', 5, '0xFF1E793A'], ['0xFF239C46'], ['0xFF28B04F']]*)
GameCreateBtn.OnEvent('Click', (*) => CreateGame())
CreateGame() {
	If !Location := FileSelect('D', 'C:\', 'Select where to create the game folder') {
		Return
	}
	Location := Trim(Location, '\')
	Location .= '\Age of Empires II'
	PB.Opt('Range1-3')
	If DirExist(Location) {
		If 'Yes' != MsgBox('The game folder already created at this location!`nOverwrite?', 'Info', 0x30 + 0x4) {
			Return
		}
	}
	PBT.Text := 'Downloading "Age of Empires II.7z"...'
	If !FileExist('data\Age of Empires II.7z')
		DownloadA(AOE_II, 'data\Age of Empires II.7z')
	PB.Value += 1
	PBT.Text := 'Decompressing "Age of Empires II.7z"...'
	RunWait(EXE ' x "data\Age of Empires II.7z" -o"' Location '" -aoa',, 'Hide')
	PBT.Text := 'Game creation completed!'
	PB.Value += 1
	MsgBox('Game creation completed!', 'Info', 0x40)
	Run(Location)
	PB.Value := 0
	PBT.Text := '---'
}
Game.SetFont('s10')
SelectGameBtn := Game.AddButton('w363', 'Select/Choose')
SelectGameBtn.OnEvent('Click', (*) => SelectGame())
CreateImageButton(SelectGameBtn, 0, [['0xFFFFFFFF',,, 3, '0xFFB2B2B2'], ['0xFFE6E6E6'], ['0xFFCCCCCC']]*)
SelectGame(Location := '') {
	Gameoff.Value := 'app\gameoff.png'
	If !Location {
		If !Location := FileSelect('D', 'C:\', 'Select the game folder to repair') {
			Return
		}
	}
	Location := Trim(Location, '\')
	If !IsValidSelection(&Location) {
		Return
	}
	For Location in AllGameLocation {
		AllGameLocation[Location] := 0
	}
	If !AllGameLocation.Has(Location) {
		GameLocation.Add([Location])
		FileAppend(Location '`n', 'GameLocation')
	}
	AllGameLocation[Location] := 1
	GameLocation.Choose(Location)
	Gameoff.Value := 'app\game.png'
	UpdateSelection()
}
UpdateSelection() {
	O := FileOpen('GameLocation', 'w')
	For Location, S in AllGameLocation {
		O.Write((S ? '>' : '') Location '`n')
	}
	O.Close()
}
Game.SetFont('s8 norm')
RepairGame := Game.AddButton('w363 Disabled', 'Repair')
;RepairGame.OnEvent('Click', (*) => RepairGame())
;RepairGame() {
;	If !Location := FileSelect('D', 'C:\', 'Select the game folder to repair') {
;		Return
;	}
;	Location := Trim(Location, '\')
;	If !IsValidSelection(&Location) {
;		Return
;	}
;	For Each, Parts in AOE_II {
;		Loop Parts[2] {
;			SplitPath(Parts[1] A_Index, &OutFileName)
;			PBT.Text := 'Getting ' OutFileName '...'
;			If !FileExist(A_Temp '\' OutFileName) {
;				Download(Parts[1] A_Index, A_Temp '\' OutFileName)
;			}
;			PBT.Text := 'Got ' OutFileName
;			PB.Value += 1
;		}
;	}
;	Log := {Corrupted: [], Missing: [], Result: "", Count: 0}
;	PBT.Text := 'Scanning your game...'
;	For File, Hash in Hashs {
;		If !FileExist(Location '\' File) {
;			If Log.Missing.Length < 10
;				Log.Result .= '[ ' File ' ] - Missing`n'
;			Log.Missing.Push(File)
;			Continue
;		}
;		If !DirExist(Location '\' File) && HashFile(Location '\' File) != Hash {
;			If Log.Corrupted.Length < 10
;				Log.Result .= '[ ' File ' ] - Unknown/Corrupted`n'
;			Log.Corrupted.Push(File)
;		}
;	}
;	If (Log.Missing.Length + Log.Corrupted.Length) >= 10
;		Log.Result .= '<...>'
;	PB.Value += 1
;	PBT.Text := 'Scan complete!'
;	If 'Yes' = Msgbox(Log.Result ? 'Found ' (Log.Missing.Length + Log.Corrupted.Length) ' issue(s)!`n`n' Log.Result '`n`nWant to fix them now?' : 'All game files seems good!', 'Info', Log.Result ? 0x30 + 0x4 : 0x40) {
;		PB.Value := 0
;		PB.Opt('Range1-' (Log.Missing.Length + Log.Corrupted.Length) * 3)
;		For Missed in Log.Missing {
;			For Each, Parts in AOE_II {
;				SplitPath(Parts[1] '1', &OutFileName)
;				PBT.Text := 'Restoring: "' Missed '"...'
;				RunWait(EXE ' x "' A_Temp '\' OutFileName '" -o"' Location '" "' Missed '" -aoa',, 'Hide')
;				PB.Value += 1
;			}
;		}
;		For Corrupt in Log.Corrupted {
;			For Each, Parts in AOE_II {
;				SplitPath(Parts[1] '1', &OutFileName)
;				PBT.Text := 'Repairing: "' Corrupt '"...'
;				RunWait(EXE ' x "' A_Temp '\' OutFileName '" -o"' Location '" "' Corrupt '" -aoa',, 'Hide')
;				PB.Value += 1
;			}
;		}
;		MsgBox('Game repair completed!', 'Info', 0x40)
;	}
;	PB.Value := 0
;	PBT.Text := '---'
;}
PB := Game.AddProgress('w363 -Smooth Range1-13')
PBT := Game.AddEdit('w363 Center -E0x200 ReadOnly', '---')
Game.Show()
IsValidSelection(&Location) {
	If InStr(Location, '>') {
		Location := SubStr(Location, 2)
	}
	If !FileExist(Location '\empires2.exe') {
		Loop Files, Location '\*', 'D' {
			If FileExist(Location '\' A_LoopFileName '\empires2.exe') {
				If 'Yes' = MsgBox('Do you mean to select this location:`n"' Location '\' A_LoopFileName '\"`n ?', 'Info', 0x40 + 0x4) {
					Location := Location '\' A_LoopFileName
					Break
				}
			}
		}
		If !FileExist(Location '\empires2.exe') {
			SplitPath(Location, , &Parent)
			If FileExist(Parent '\empires2.exe') {
				If 'Yes' = MsgBox('Do you mean to select this location:`n"' Parent '\"`n ?', 'Info', 0x40 + 0x4) {
					Location := Parent
				}
			}
		}
	}
	Similarity := 0
	GameFiles := ["00000409.016", "00000409.256", "clcd16.dll", "clcd32.dll", "clokspl.exe", "DPLAY61A.EXE", "dplayerx.dll", "drvmgt.dll", "EBUEula.dll", "ebueulax.dll", "EBUSetup.sem", "empires2.exe", "EMPIRES2.ICD", "EULA.RTF", "EULAx.RTF", "HA312W32.DLL", "language.dll", "language_x1.dll", "Readme.rtf", "Readmex.rtf", "scenariobkg.bmp", "SETUPENU.DLL", "SHW32.DLL", "STPENUX.DLL", "version.txt", "age2_x1\00000409.016", "age2_x1\00000409.256", "age2_x1\age2_x1.exe", "age2_x1\AGE2_X1.ICD", "age2_x1\age2_x2.exe", "age2_x1\clcd16.dll", "age2_x1\clcd32.dll", "age2_x1\clokspl.exe", "age2_x1\dplayerx.dll", "age2_x1\drvmgt.dll", "age2_x1\FixAoFE.exe", "age2_x1\mcp.dll", "AI\AI.txt", "Avi\Avi.txt", "Campaign\cam1.cpn", "Campaign\cam2.cpn", "Campaign\cam3.cpn", "Campaign\cam4.cpn", "Campaign\cam8.cpn", "Campaign\xcam1.cpx", "Campaign\xcam2.cpx", "Campaign\xcam3.cpx", "Campaign\xcam4.cpx", "Campaign\Media\backgrd.slp", "Campaign\Media\backgrd1.pal", "Campaign\Media\backgrd1.sin", "Campaign\Media\backgrd1.SLP", "Campaign\Media\backgrd2.pal", "Campaign\Media\backgrd2.sin", "Campaign\Media\backgrd2.SLP", "Campaign\Media\backgrd3.pal", "Campaign\Media\backgrd3.sin", "Campaign\Media\backgrd3.SLP", "Campaign\Media\backgrd4.pal", "Campaign\Media\backgrd4.sin", "Campaign\Media\backgrd4.SLP", "Campaign\Media\backgrd8.pal", "Campaign\Media\backgrd8.sin", "Campaign\Media\backgrd8.SLP", "Campaign\Media\c1s1_beg.mm", "Campaign\Media\c1s1_beg.slp", "Campaign\Media\c1s1_end.mm", "Campaign\Media\c1s1_end.slp", "Campaign\Media\c1s2_beg.mm", "Campaign\Media\c1s2_beg.slp", "Campaign\Media\c1s2_end.mm", "Campaign\Media\c1s2_end.slp", "Campaign\Media\c1s3_beg.mm", "Campaign\Media\c1s3_beg.slp", "Campaign\Media\c1s3_end.mm", "Campaign\Media\c1s3_end.slp", "Campaign\Media\c1s4_beg.mm", "Campaign\Media\c1s4_beg.slp", "Campaign\Media\c1s4_end.mm", "Campaign\Media\c1s4_end.slp", "Campaign\Media\c1s5_beg.mm", "Campaign\Media\c1s5_beg.slp", "Campaign\Media\c1s5_end.mm", "Campaign\Media\C1s5_END.slp", "Campaign\Media\c1s6_beg.mm", "Campaign\Media\c1s6_beg.slp", "Campaign\Media\c1s6_end.mm", "Campaign\Media\C1s6_end.slp", "Campaign\Media\c2s1_beg.mm", "Campaign\Media\C2s1_beg.slp", "Campaign\Media\c2s1_end.mm", "Campaign\Media\C2S1_END.SLP", "Campaign\Media\c2s2_beg.mm", "Campaign\Media\C2S2_BEG.SLP", "Campaign\Media\c2s2_end.mm", "Campaign\Media\C2S2_END.SLP", "Campaign\Media\c2s3_beg.mm", "Campaign\Media\C2S3_BEG.SLP", "Campaign\Media\c2s3_end.mm", "Campaign\Media\C2S3_END.SLP", "Campaign\Media\c2s4_beg.mm", "Campaign\Media\C2S4_BEG.SLP", "Campaign\Media\c2s4_end.mm", "Campaign\Media\C2S4_END.SLP", "Campaign\Media\c2s5_beg.mm", "Campaign\Media\C2S5_BEG.SLP", "Campaign\Media\c2s5_end.mm", "Campaign\Media\C2S5_END.SLP", "Campaign\Media\c2s6_beg.mm", "Campaign\Media\C2S6_BEG.SLP", "Campaign\Media\c2s6_end.mm", "Campaign\Media\C2S6_END.SLP", "Campaign\Media\c3s1_beg.mm", "Campaign\Media\C3s1_bEG.slp", "Campaign\Media\c3s1_end.mm", "Campaign\Media\c3s1_end.SLP", "Campaign\Media\c3s2_beg.mm", "Campaign\Media\c3s2_beg.SLP", "Campaign\Media\c3s2_end.mm", "Campaign\Media\c3s2_end.SLP", "Campaign\Media\c3s3_beg.mm", "Campaign\Media\c3s3_beg.SLP", "Campaign\Media\c3s3_end.mm", "Campaign\Media\c3s3_end.SLP", "Campaign\Media\c3s4_beg.mm", "Campaign\Media\c3s4_beg.SLP", "Campaign\Media\c3s4_end.mm", "Campaign\Media\c3s4_end.SLP", "Campaign\Media\c3s5_beg.mm", "Campaign\Media\c3s5_beg.SLP", "Campaign\Media\c3s5_end.mm", "Campaign\Media\c3s5_end.SLP", "Campaign\Media\c3s6_beg.mm", "Campaign\Media\c3s6_beg.SLP", "Campaign\Media\c3s6_end.mm", "Campaign\Media\c3s6_end.SLP", "Campaign\Media\c4s1_beg.mm", "Campaign\Media\c4s1_beg.SLP", "Campaign\Media\c4s1_end.mm", "Campaign\Media\c4s1_end.SLP", "Campaign\Media\c4s2_beg.mm", "Campaign\Media\c4s2_beg.SLP", "Campaign\Media\c4s2_end.mm", "Campaign\Media\c4s2_end.SLP", "Campaign\Media\c4s3_beg.mm", "Campaign\Media\c4s3_beg.SLP", "Campaign\Media\c4s3_end.mm", "Campaign\Media\c4s3_end.SLP", "Campaign\Media\c4s4_beg.mm", "Campaign\Media\c4s4_beg.SLP", "Campaign\Media\c4s4_end.mm", "Campaign\Media\c4s4_end.SLP", "Campaign\Media\c4s5_beg.mm", "Campaign\Media\c4s5_beg.SLP", "Campaign\Media\c4s5_end.mm", "Campaign\Media\c4s5_end.SLP", "Campaign\Media\c4s6_beg.mm", "Campaign\Media\c4s6_beg.SLP", "Campaign\Media\c4s6_end.mm", "Campaign\Media\c4s6_end.SLP", "Campaign\Media\c8s1_beg.mm", "Campaign\Media\c8s1_beg.SLP", "Campaign\Media\c8s1_end.mm", "Campaign\Media\c8s1_end.SLP", "Campaign\Media\c8s2_beg.mm", "Campaign\Media\c8s2_beg.SLP", "Campaign\Media\c8s2_end.mm", "Campaign\Media\c8s2_end.SLP", "Campaign\Media\c8s3_beg.mm", "Campaign\Media\c8s3_beg.SLP", "Campaign\Media\c8s3_end.mm", "Campaign\Media\c8s3_end.SLP", "Campaign\Media\c8s4_beg.mm", "Campaign\Media\c8s4_beg.SLP", "Campaign\Media\c8s4_end.mm", "Campaign\Media\c8s4_end.SLP", "Campaign\Media\c8s5_beg.mm", "Campaign\Media\c8s5_beg.SLP", "Campaign\Media\c8s5_end.mm", "Campaign\Media\c8s5_end.SLP", "Campaign\Media\c8s6_beg.mm", "Campaign\Media\c8s6_beg.SLP", "Campaign\Media\c8s6_end.mm", "Campaign\Media\c8s6_end.SLP", "Campaign\Media\c8s7_beg.mm", "Campaign\Media\c8s7_beg.SLP", "Campaign\Media\c8s7_end.mm", "Campaign\Media\c8s7_end.SLP", "Campaign\Media\cam1.bln", "Campaign\Media\cam2.bln", "Campaign\Media\cam3.bln", "Campaign\Media\cam4.bln", "Campaign\Media\cam8.bln", "Campaign\Media\Intro.bln", "Campaign\Media\Intro.mm", "Campaign\Media\Intro.pal", "Campaign\Media\Intro.sin", "Campaign\Media\Intro.slp", "Campaign\Media\Introbkg.slp", "Data\blendomatic.dat", "Data\BlkEdge.Dat", "Data\closedpw.exe", "Data\empires2.dat", "Data\empires2_x1.dat", "Data\FilterMaps.dat", "Data\GAMEDATA.DRS", "Data\gamedata_x1.drs", "Data\graphics.drs", "Data\interfac.drs", "Data\lightMaps.dat", "Data\list.cr", "Data\list.crx", "Data\LoQMaps.dat", "Data\PatternMasks.dat", "Data\shadow.col", "Data\sounds.drs", "Data\sounds_x1.drs", "Data\STemplet.dat", "Data\Terrain.drs", "Data\TileEdge.Dat", "Data\view_icm.dat", "Data\Load\Load.txt", "Games\age2_x2.xml", "Games\Forgotten Empires\Data\empires2_x1_p1.dat", "Games\Forgotten Empires\Data\gamedata_x1.drs", "Games\Forgotten Empires\Data\gamedata_x1_p1.drs", "Games\Forgotten Empires\Data\language_x1_p1.dll", "Games\Forgotten Empires\History\Incas.txt", "Games\Forgotten Empires\History\Indians.txt", "Games\Forgotten Empires\History\Italians.txt", "Games\Forgotten Empires\History\Magyars.txt", "Games\Forgotten Empires\History\Slavs.txt", "Games\Forgotten Empires\Scenario\'Legionnaires on the Horizon!'.scx", "Games\Forgotten Empires\Scenario\24th of August, 410 - The Sack of Rome.scx", "Games\Forgotten Empires\Scenario\Alaric.cpx", "Games\Forgotten Empires\Scenario\Cysion - Lushful Forest.scx", "Games\Forgotten Empires\Scenario\Early 410 - Emperor of the West.scx", "Games\Forgotten Empires\Scenario\Fishing.scx", "Games\Forgotten Empires\Scenario\Last stop before Baghdad.scx", "Games\Forgotten Empires\Scenario\Prussian Uprisings.scx", "Games\Forgotten Empires\Scenario\September 408 - All Roads lead to a besieged city.scx", "Games\Forgotten Empires\Scenario\Siege of Haengju.scx", "Games\Forgotten Empires\Script.AI\Barbarian.ai", "Games\Forgotten Empires\Script.AI\Barbarian.per", "Games\Forgotten Empires\Script.AI\Crusade.ai", "Games\Forgotten Empires\Script.AI\Crusade.per", "Games\Forgotten Empires\Script.AI\Principality.ai", "Games\Forgotten Empires\Script.AI\Principality.per", "Games\Forgotten Empires\Script.AI\Promi.ai", "Games\Forgotten Empires\Script.AI\Promi.per", "Games\Forgotten Empires\Script.AI\resign - AI Ladder.per", "Games\Forgotten Empires\Script.AI\resign - land map.per", "Games\Forgotten Empires\Script.AI\Standard AI.ai", "Games\Forgotten Empires\Script.AI\Standard AI.per", "Games\Forgotten Empires\Script.AI\The Horde.ai", "Games\Forgotten Empires\Script.AI\The Horde.per", "Games\Forgotten Empires\Script.AI\The Khanate.ai", "Games\Forgotten Empires\Script.AI\The Khanate.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\AztecSuperRush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\CA.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Castles.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Commands.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\CommandsTG.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\DeathMatch.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\DMConstants.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Drush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\FlankAggressiveness.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\HardestCheats.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\HeavySkirms.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\IslandsFireEco.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\IslandsGalleyEco.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\KnightRush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\MayanEagleRush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\MIX.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\MonksAndTrebs.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\OnlyMeso.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\PocketAggressiveness.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\RaidTheCamps.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Resigning.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\RuleBuffer.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\ScoutArcher.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\ScoutDefence.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\ScoutSkirm.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\SLING.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies1v1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\StrategiesTG.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\SuicidalKnightRush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\TheAntiCysion.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\TheGreatWall.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\TheGrowlOfTheJaguar.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\TurkSaraExtra.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\UnusualSwitch.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Uusi tekstiasiakirja.txt", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\WallAndBoom.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\WonderAssault.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\WonderVictory.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\AddedDrush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\ARCHER1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\ARCHER2.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\BOMBARDMENT.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\CASTLEPUSH.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\CASTLESLING.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\EternalDrush.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FastEagles.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC10.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC11.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC12.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC15.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC16.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC17.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC2BOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC2FI.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC3.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC4.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC7.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FC9FI.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FIARCHER.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FIMONKTREB.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\FULLSKIRM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\JAGUARS.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\KBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\KNIGHTARCHER.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\KNIGHTBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\KRUSH.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MAA1ARCHER1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MAA1ARCHER2.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MAA2.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MANGOPUSH.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MISSIONARY.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MONGOLBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MONKBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\MUSH.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\PocketWaterFC.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\RANGEDBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SCORPS.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SCOUT1ARCHER1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SCOUT1SKIRM1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SKIRMBOOM.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SMUSH.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\SUPERSCOUTS.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\TRASH1.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Turtles.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Uusi tekstiasiakirja.txt", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\WALLS.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\WarElephants.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\WarGalleys.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-camel-cannoneer.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-cannoneers.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-champ-cannoneer.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-champ-turtle.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-champs.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-eagles.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-halb-husk.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-halb-scorpion.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-husk-champ.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-pala-turtle.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-palas.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-UU-champ.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\dm-UU.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\DM\Uusi tekstiasiakirja.txt", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set01.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set02.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set03.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set04.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set05.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set06.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Set07.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\SuperTraitor.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Traitor.per", "Games\Forgotten Empires\Script.AI\Barbarian_2.0\Strategies\Personality\Uusi tekstiasiakirja.txt", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Amphibian.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Army Selection.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Attack evolution.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Attack rules.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Battle behavior.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Boar Hunting.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Alpha.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Betha - 1c.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Betha - UP.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Omega - 1c.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Omega - UP.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Zero - 1c.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Buildings Zero - UP.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Calculate gatherers wood-marathon.xlsx", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Camps - 1c.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Camps - UP.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Chat.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Constants FactID.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Constants for civs.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Constants.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Control Upgrades.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Extra Upgrades.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\FC Archery.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Archery-3.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Man-at-arms.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Market Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Market Swords-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Market Swords.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Flush Swords-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Forgotten Empires Constants.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\g-jollygoal-0.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Gatherer percentages Dark Age.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Gatherer percentages Late Game.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Gatherer-Dynamic percentages Late Feudal.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\General Economy.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Initial strategic numbers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Main Upgrades.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Marathon XLS.zip", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Market rules.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Military superiority 2.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Military superiority.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Navy superiority.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Obsolet strategic numbers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\resign - AI Ladder.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Resign - Human.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Sheep.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Flush Archery-3.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Flush Man-at-arms.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Flush Market Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Flush Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Flush Swords-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Trush Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy Default - Trush Swords-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Strategy selection.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Threat rules.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Trebuchet.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Tribute.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Trush Scouts-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Trush Swords-Archers.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\TS Building.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\TSA Defensive.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\TSA.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Unit Training.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\UP initialization.per", "Games\Forgotten Empires\Script.AI\Crusade 4.42\Wonder Race.per", "Games\Forgotten Empires\Script.AI\Promi\aofe.per", "Games\Forgotten Empires\Script.AI\Promi\boarhunting.per", "Games\Forgotten Empires\Script.AI\Promi\buildings.per", "Games\Forgotten Empires\Script.AI\Promi\Const.per", "Games\Forgotten Empires\Script.AI\Promi\gatherers.per", "Games\Forgotten Empires\Script.AI\Promi\General.per", "Games\Forgotten Empires\Script.AI\Promi\Init.per", "Games\Forgotten Empires\Script.AI\Promi\interaction.per", "Games\Forgotten Empires\Script.AI\Promi\researches.per", "Games\Forgotten Empires\Script.AI\Promi\resign.per", "Games\Forgotten Empires\Script.AI\Promi\Teamsuperiority.per", "Games\Forgotten Empires\Script.AI\Promi\threats.per", "Games\Forgotten Empires\Script.AI\Promi\trade.per", "Games\Forgotten Empires\Script.AI\Promi\TSA.per", "Games\Forgotten Empires\Script.AI\Promi\units.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite ai petersen rules.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen castle.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen civ loads.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen constants.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen deathmatch.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen difficulty loads.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen dip boomer.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen dip bully.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen dip feeder.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen dip insult.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen dip liar.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen diplomacy.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen fishboat.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen full tech.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen gather.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen groups.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen map loads.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen market.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen resign.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen rush.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen supplement.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen tower.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen upgrades.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen warboat island.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen warboat.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite petersen wonder.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite randomgame.ai", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite randomgame.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite wonder kill.per", "Games\Forgotten Empires\Script.AI\STD AI DM FIX\elite wonder rush.per", "Games\Forgotten Empires\Script.RM\Acropolis.rms", "Games\Forgotten Empires\Script.RM\Budapest.rms", "Games\Forgotten Empires\Script.RM\Cenotes.rms", "Games\Forgotten Empires\Script.RM\Golden Pit.rms", "Games\Forgotten Empires\Script.RM\Hideout.rms", "Games\Forgotten Empires\Script.RM\Hill Fort.rms", "Games\Forgotten Empires\Script.RM\Land of Lakes.rms", "Games\Forgotten Empires\Script.RM\Lombardia.rms", "Games\Forgotten Empires\Script.RM\MegaRandom Beta.rms", "Games\Forgotten Empires\Script.RM\Random.txt", "Games\Forgotten Empires\Script.RM\Steppe.rms", "Games\Forgotten Empires\Script.RM\Team Arena.rms", "Games\Forgotten Empires\Script.RM\Valley.rms", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 5.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 6.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 7.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 8.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Alaric 9.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Athaulf 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Athaulf 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Athaulf's scout.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Captain 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Guard 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Informant 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Pikeman 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Pikeman 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Scout 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Scout 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Scout 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Scout 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Timer 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Timer 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 2 - Timer 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Alaric 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Alaric 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Alaric 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Alaric 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Alaric 5.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Bodyguard 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Condottiero 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Knight 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Knight 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Knight 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Mercenary 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - sailor 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Saurus 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Soldier 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 3 - Village Knight 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 5.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Alaric 6.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 5.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 6.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 7.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Athaulf 8.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Caelir 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - centurion 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Civilian 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Knight 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Soldier a.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric 4 - Soldier b.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric Scenario - Guard.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Alaric 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Alaric 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Monk.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Prisoners.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Refugee.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Scout.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 1.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 2.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 3.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 4.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 5.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 6.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 7.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 8.mp3", "Games\Forgotten Empires\Sound\Scenario\Alaric scenario 1 - Soldier 9.mp3", "Games\Forgotten Empires\Sound\stream\INCAS.mp3", "Games\Forgotten Empires\Sound\stream\INDIANS.mp3", "Games\Forgotten Empires\Sound\stream\ITALIANS.mp3", "Games\Forgotten Empires\Sound\stream\LOST.mp3", "Games\Forgotten Empires\Sound\stream\MAGYARS.mp3", "Games\Forgotten Empires\Sound\stream\SLAVS.mp3", "Games\Forgotten Empires\Sound\stream\xopen.mp3", "History\Armies.txt", "History\ArmiesMongols.txt", "History\ArmiesOrg.txt", "History\ArmiesStrat.txt", "History\ArmiesTactics.txt", "History\Aztecs.txt", "History\barbarianinvaders.txt", "History\British original.txt", "History\british regular.txt", "History\british test.txt", "History\british.txt", "History\Byzantines.txt", "History\CastleDefenses.txt", "History\CastleEvolution.txt", "History\Castles.txt", "History\CastleSiege.txt", "History\Celts.txt", "History\charlemagne.txt", "History\Chinese.txt", "History\darkagereligion.txt", "History\darkages.txt", "History\DarkArmies.txt", "History\economy.txt", "History\feudalcontract.txt", "History\feudalism.txt", "History\feudalismdecline.txt", "History\Franks.txt", "History\Goths.txt", "History\Gunpowder.txt", "History\history.txt", "History\Huns.txt", "History\Japanese.txt", "History\Knights.txt", "History\Koreans.txt", "History\latemiddleages.txt", "History\Mayans.txt", "History\middleages.txt", "History\Mongols.txt", "History\Naval.txt", "History\Persians.txt", "History\politics.txt", "History\religion.txt", "History\renaissance.txt", "History\Saracens.txt", "History\Spanish.txt", "History\technology.txt", "History\Teutons.txt", "History\thecrusades.txt", "History\thefallofrome.txt", "History\themanor.txt", "History\thevikings.txt", "History\Turks.txt", "History\Vikings.txt", "History\Warfare.txt", "History\Weapons.txt", "History\WeaponsCav.txt", "History\WeaponsHand.txt", "History\WeaponsMissile.txt", "Learn\Learn.txt", "Random\Random.txt", "SaveGame\SaveGame.txt", "SaveGame\Multi\Multi.txt", "Scenario\scenario.inf", "Sound\campaign\c1s1.mp3", "Sound\campaign\c1s1end.mp3", "Sound\campaign\c1s2.mp3", "Sound\campaign\c1s2end.mp3", "Sound\campaign\c1s3.mp3", "Sound\campaign\c1s3end.mp3", "Sound\campaign\c1s4.mp3", "Sound\campaign\c1s4end.mp3", "Sound\campaign\c1s5.mp3", "Sound\campaign\c1s5end.mp3", "Sound\campaign\c1s6.mp3", "Sound\campaign\c1s6end.mp3", "Sound\campaign\c2s1.mp3", "Sound\campaign\c2s1end.mp3", "Sound\campaign\c2s2.mp3", "Sound\campaign\c2s2end.mp3", "Sound\campaign\c2s3.mp3", "Sound\campaign\c2s3end.mp3", "Sound\campaign\c2s4.mp3", "Sound\campaign\c2s4end.mp3", "Sound\campaign\c2s5.mp3", "Sound\campaign\c2s5end.mp3", "Sound\campaign\c2s6.mp3", "Sound\campaign\c2s6end.mp3", "Sound\campaign\c3s1.mp3", "Sound\campaign\c3s1end.mp3", "Sound\campaign\c3s2.mp3", "Sound\campaign\c3s2end.mp3", "Sound\campaign\c3s3.mp3", "Sound\campaign\c3s3end.mp3", "Sound\campaign\c3s4.mp3", "Sound\campaign\c3s4end.mp3", "Sound\campaign\c3s5.mp3", "Sound\campaign\c3s5end.mp3", "Sound\campaign\c3s6.mp3", "Sound\campaign\c3s6end.mp3", "Sound\campaign\c4s1.mp3", "Sound\campaign\c4s1end.mp3", "Sound\campaign\c4s2.mp3", "Sound\campaign\c4s2end.mp3", "Sound\campaign\c4s3.mp3", "Sound\campaign\c4s3end.mp3", "Sound\campaign\c4s4.mp3", "Sound\campaign\c4s4end.mp3", "Sound\campaign\c4s5.mp3", "Sound\campaign\c4s5end.mp3", "Sound\campaign\c4s6.mp3", "Sound\campaign\c4s6end.mp3", "Sound\campaign\c8s1.mp3", "Sound\campaign\c8s1end.mp3", "Sound\campaign\c8s2.mp3", "Sound\campaign\c8s2end.mp3", "Sound\campaign\c8s3.mp3", "Sound\campaign\c8s3end.mp3", "Sound\campaign\c8s4.mp3", "Sound\campaign\c8s4end.mp3", "Sound\campaign\c8s5.mp3", "Sound\campaign\c8s5end.mp3", "Sound\campaign\c8s6.mp3", "Sound\campaign\c8s6end.mp3", "Sound\campaign\c8s7.mp3", "Sound\campaign\c8s7end.mp3", "Sound\campaign\intro.mp3", "Sound\scenario\a1a.mp3", "Sound\scenario\A1AA.mp3", "Sound\scenario\a1ab.mp3", "Sound\scenario\a1ac.mp3", "Sound\scenario\a1ad.mp3", "Sound\scenario\a1ae.mp3", "Sound\scenario\a1af.mp3", "Sound\scenario\a1ag.mp3", "Sound\scenario\a1ah.mp3", "Sound\scenario\a1b.mp3", "Sound\scenario\a1c.mp3", "Sound\scenario\a1d.mp3", "Sound\scenario\a1e.mp3", "Sound\scenario\a1f.mp3", "Sound\scenario\a1g.mp3", "Sound\scenario\a1h.mp3", "Sound\scenario\a1i.mp3", "Sound\scenario\a1j.mp3", "Sound\scenario\a1k.mp3", "Sound\scenario\a1l.mp3", "Sound\scenario\a1m.mp3", "Sound\scenario\a1n.mp3", "Sound\scenario\a1o.mp3", "Sound\scenario\a1p.mp3", "Sound\scenario\a1q.mp3", "Sound\scenario\a1r.mp3", "Sound\scenario\a1s.mp3", "Sound\scenario\a1t.mp3", "Sound\scenario\a1u.mp3", "Sound\scenario\a1v.mp3", "Sound\scenario\a1w.mp3", "Sound\scenario\a1x.mp3", "Sound\scenario\a1xa.mp3", "Sound\scenario\a1y.mp3", "Sound\scenario\a1z.mp3", "Sound\scenario\a2a.mp3", "Sound\scenario\a2b.mp3", "Sound\scenario\a2c.mp3", "Sound\scenario\a2d.mp3", "Sound\scenario\a2e.mp3", "Sound\scenario\a2f.mp3", "Sound\scenario\a2g.mp3", "Sound\scenario\a2h.mp3", "Sound\scenario\a2i.mp3", "Sound\scenario\a2j.mp3", "Sound\scenario\a2k.mp3", "Sound\scenario\a2l.mp3", "Sound\scenario\a2m.mp3", "Sound\scenario\a2n.mp3", "Sound\scenario\a2o.mp3", "Sound\scenario\a2p.mp3", "Sound\scenario\a2q.mp3", "Sound\scenario\a2r.mp3", "Sound\scenario\a2s.mp3", "Sound\scenario\a3a.mp3", "Sound\scenario\a3b.mp3", "Sound\scenario\a3c.mp3", "Sound\scenario\a3d.mp3", "Sound\scenario\a3e.mp3", "Sound\scenario\a3f.mp3", "Sound\scenario\a3g.mp3", "Sound\scenario\a3h.mp3", "Sound\scenario\a3i.mp3", "Sound\scenario\a3j.mp3", "Sound\scenario\a3k.mp3", "Sound\scenario\a3l.mp3", "Sound\scenario\a3m.mp3", "Sound\scenario\a3n.mp3", "Sound\scenario\a3o.mp3", "Sound\scenario\a3p.mp3", "Sound\scenario\a4a.mp3", "Sound\scenario\a4b.mp3", "Sound\scenario\a4c.mp3", "Sound\scenario\a4d.mp3", "Sound\scenario\a4e.mp3", "Sound\scenario\a4f.mp3", "Sound\scenario\a5a.mp3", "Sound\scenario\a5b.mp3", "Sound\scenario\a5c.mp3", "Sound\scenario\a5d.mp3", "Sound\scenario\a6a.mp3", "Sound\scenario\a6b.mp3", "Sound\scenario\Age Up.mp3", "Sound\scenario\b1a.mp3", "Sound\scenario\b1b.mp3", "Sound\scenario\b1c.mp3", "Sound\scenario\b1d.mp3", "Sound\scenario\b2a.mp3", "Sound\scenario\b2b.mp3", "Sound\scenario\b2c.mp3", "Sound\scenario\b3a.mp3", "Sound\scenario\b3aa.mp3", "Sound\scenario\b3b.mp3", "Sound\scenario\b3c.mp3", "Sound\scenario\b3d.mp3", "Sound\scenario\b3e.mp3", "Sound\scenario\b4b.mp3", "Sound\scenario\b4c.mp3", "Sound\scenario\b4d.mp3", "Sound\scenario\b4e.mp3", "Sound\scenario\b4f.mp3", "Sound\scenario\b5a.mp3", "Sound\scenario\b5b.mp3", "Sound\scenario\b5c.mp3", "Sound\scenario\b5d.mp3", "Sound\scenario\b5e.mp3", "Sound\scenario\b5f.mp3", "Sound\scenario\b5g.mp3", "Sound\scenario\b5h.mp3", "Sound\scenario\b5i.mp3", "Sound\scenario\b5j.mp3", "Sound\scenario\b5k.mp3", "Sound\scenario\b5l.mp3", "Sound\scenario\b5m.mp3", "Sound\scenario\b5n.mp3", "Sound\scenario\b5o.mp3", "Sound\scenario\b5p.mp3", "Sound\scenario\b5q.mp3", "Sound\scenario\b6a.mp3", "Sound\scenario\b6b.mp3", "Sound\scenario\b6c.mp3", "Sound\scenario\b6d.mp3", "Sound\scenario\b6e.mp3", "Sound\scenario\b6f.mp3", "Sound\scenario\b6g.mp3", "Sound\scenario\b6h.mp3", "Sound\scenario\b6i.mp3", "Sound\scenario\b6j.mp3", "Sound\scenario\b6k.mp3", "Sound\scenario\b6l.mp3", "Sound\scenario\b6m.mp3", "Sound\scenario\b6n.mp3", "Sound\scenario\c1a.mp3", "Sound\scenario\c1b.mp3", "Sound\scenario\c1c.mp3", "Sound\scenario\c1d.mp3", "Sound\scenario\c1e.mp3", "Sound\scenario\c2a.mp3", "Sound\scenario\c2b.mp3", "Sound\scenario\c2c.mp3", "Sound\scenario\c2d.mp3", "Sound\scenario\c2e.mp3", "Sound\scenario\c2f.mp3", "Sound\scenario\c2g.mp3", "Sound\scenario\c2h.mp3", "Sound\scenario\c2i.mp3", "Sound\scenario\c2j.mp3", "Sound\scenario\c2k.mp3", "Sound\scenario\c2l.mp3", "Sound\scenario\c3a.mp3", "Sound\scenario\c3b.mp3", "Sound\scenario\c3c.mp3", "Sound\scenario\c3d.mp3", "Sound\scenario\c3e.mp3", "Sound\scenario\c3f.mp3", "Sound\scenario\c3g.mp3", "Sound\scenario\c3h.mp3", "Sound\scenario\c4a.mp3", "Sound\scenario\c4b.mp3", "Sound\scenario\c4c.mp3", "Sound\scenario\c4d.mp3", "Sound\scenario\c4e.mp3", "Sound\scenario\c4f.mp3", "Sound\scenario\c4g.mp3", "Sound\scenario\c4h.mp3", "Sound\scenario\c4i.mp3", "Sound\scenario\c4j.mp3", "Sound\scenario\c4ja.mp3", "Sound\scenario\c4k.mp3", "Sound\scenario\c5a.mp3", "Sound\scenario\c5b.mp3", "Sound\scenario\c5c.mp3", "Sound\scenario\c5ca.mp3", "Sound\scenario\c5d.mp3", "Sound\scenario\c5da.mp3", "Sound\scenario\c5e.mp3", "Sound\scenario\c5f.mp3", "Sound\scenario\c5g.mp3", "Sound\scenario\c5h.mp3", "Sound\scenario\c5i.mp3", "Sound\scenario\c5j.mp3", "Sound\scenario\c5k.mp3", "Sound\scenario\c5l.mp3", "Sound\scenario\c5m.mp3", "Sound\scenario\c5n.mp3", "Sound\scenario\c5o.mp3", "Sound\scenario\c5p.mp3", "Sound\scenario\c5q.mp3", "Sound\scenario\c5r.mp3", "Sound\scenario\c6a.mp3", "Sound\scenario\c6b.mp3", "Sound\scenario\c6c.mp3", "Sound\scenario\c6d.mp3", "Sound\scenario\c6e.mp3", "Sound\scenario\c6f.mp3", "Sound\scenario\c6g.mp3", "Sound\scenario\c6h.mp3", "Sound\scenario\c6i.mp3", "Sound\scenario\c7a.mp3", "Sound\scenario\c7b.mp3", "Sound\scenario\c7c.mp3", "Sound\scenario\c7d.mp3", "Sound\scenario\c7e.mp3", "Sound\scenario\c7f.mp3", "Sound\scenario\c7g.mp3", "Sound\scenario\c7h.mp3", "Sound\scenario\c8a.mp3", "Sound\scenario\c8b.mp3", "Sound\scenario\c8c.mp3", "Sound\scenario\c8d.mp3", "Sound\scenario\c8e.mp3", "Sound\scenario\d1a.mp3", "Sound\scenario\d1b.mp3", "Sound\scenario\d1c.mp3", "Sound\scenario\e1a.mp3", "Sound\scenario\e1aa.mp3", "Sound\scenario\e1b.mp3", "Sound\scenario\e1c.mp3", "Sound\scenario\e1d.mp3", "Sound\scenario\e1e.mp3", "Sound\scenario\e1f.mp3", "Sound\scenario\e1g.mp3", "Sound\scenario\e1h.mp3", "Sound\scenario\e1j.mp3", "Sound\scenario\e1k.mp3", "Sound\scenario\e1l.mp3", "Sound\scenario\e1n.mp3", "Sound\scenario\E1o.mp3", "Sound\scenario\e1p.mp3", "Sound\scenario\e1q.mp3", "Sound\scenario\e1r.mp3", "Sound\scenario\e1s.mp3", "Sound\scenario\e1t.mp3", "Sound\scenario\e1u.mp3", "Sound\scenario\e1ua.mp3", "Sound\scenario\e1v.mp3", "Sound\scenario\e1w.mp3", "Sound\scenario\e1x.mp3", "Sound\scenario\E1Y.mp3", "Sound\scenario\e1z.mp3", "Sound\scenario\e2a.mp3", "Sound\scenario\e2b.mp3", "Sound\scenario\e2c.mp3", "Sound\scenario\e2d.mp3", "Sound\scenario\e2e.mp3", "Sound\scenario\e2f.mp3", "Sound\scenario\e2g.mp3", "Sound\scenario\e2h.mp3", "Sound\scenario\e3a.mp3", "Sound\scenario\e3b.mp3", "Sound\scenario\e3c.mp3", "Sound\scenario\e3d.mp3", "Sound\scenario\e3e.mp3", "Sound\scenario\e3f.mp3", "Sound\scenario\e3g.mp3", "Sound\scenario\e3h.mp3", "Sound\scenario\e3i.mp3", "Sound\scenario\e3j.mp3", "Sound\scenario\e3k.mp3", "Sound\scenario\e3l.mp3", "Sound\scenario\e3m.mp3", "Sound\scenario\e4a.mp3", "Sound\scenario\e4b.mp3", "Sound\scenario\e4c.mp3", "Sound\scenario\e4d.mp3", "Sound\scenario\e4e.mp3", "Sound\scenario\e4f.mp3", "Sound\scenario\e4g.mp3", "Sound\scenario\e4h.mp3", "Sound\scenario\e4i.mp3", "Sound\scenario\e4j.mp3", "Sound\scenario\e4k.mp3", "Sound\scenario\e4l.mp3", "Sound\scenario\e4m.mp3", "Sound\scenario\e4n.mp3", "Sound\scenario\e4o.mp3", "Sound\scenario\e4p.mp3", "Sound\scenario\e4q.mp3", "Sound\scenario\e4r.mp3", "Sound\scenario\e4s.mp3", "Sound\scenario\e4t.mp3", "Sound\scenario\e4u.mp3", "Sound\scenario\e4v.mp3", "Sound\scenario\e4w.mp3", "Sound\scenario\e4x.mp3", "Sound\scenario\e4y.mp3", "Sound\scenario\e5a.mp3", "Sound\scenario\e5b.mp3", "Sound\scenario\e5c.mp3", "Sound\scenario\e5d.mp3", "Sound\scenario\e5e.mp3", "Sound\scenario\e5f.mp3", "Sound\scenario\e5g.mp3", "Sound\scenario\e5h.mp3", "Sound\scenario\e5i.mp3", "Sound\scenario\e5j.mp3", "Sound\scenario\e5k.mp3", "Sound\scenario\e5l.mp3", "Sound\scenario\e6a.mp3", "Sound\scenario\e6b.mp3", "Sound\scenario\g1a.mp3", "Sound\scenario\g1b.mp3", "Sound\scenario\g1c.mp3", "Sound\scenario\g1d.mp3", "Sound\scenario\g1e.mp3", "Sound\scenario\g1f.mp3", "Sound\scenario\g1g.mp3", "Sound\scenario\g1h.mp3", "Sound\scenario\g1i.mp3", "Sound\scenario\g1j.mp3", "Sound\scenario\g1k.mp3", "Sound\scenario\g1l.mp3", "Sound\scenario\g1lold.mp3", "Sound\scenario\g1m.mp3", "Sound\scenario\g2a.mp3", "Sound\scenario\g2b.mp3", "Sound\scenario\g2c.mp3", "Sound\scenario\g2d.mp3", "Sound\scenario\g2e.mp3", "Sound\scenario\g2f.mp3", "Sound\scenario\g2g.mp3", "Sound\scenario\g2h.mp3", "Sound\scenario\g3a.mp3", "Sound\scenario\g3b.mp3", "Sound\scenario\g3c.mp3", "Sound\scenario\g3d.mp3", "Sound\scenario\g3e.mp3", "Sound\scenario\g4a.mp3", "Sound\scenario\g4b.mp3", "Sound\scenario\g4c.mp3", "Sound\scenario\g4d.mp3", "Sound\scenario\g4e.mp3", "Sound\scenario\g4f.mp3", "Sound\scenario\g4g.mp3", "Sound\scenario\g4h.mp3", "Sound\scenario\g4i.mp3", "Sound\scenario\g4j.mp3", "Sound\scenario\g5a.mp3", "Sound\scenario\g5b.mp3", "Sound\scenario\g5c.mp3", "Sound\scenario\g5d.mp3", "Sound\scenario\g5e.mp3", "Sound\scenario\g5f.mp3", "Sound\scenario\g5g.mp3", "Sound\scenario\g5h.mp3", "Sound\scenario\g5i.mp3", "Sound\scenario\g5j.mp3", "Sound\scenario\g6a.mp3", "Sound\scenario\g6b.mp3", "Sound\scenario\g6c.mp3", "Sound\scenario\g6d.mp3", "Sound\scenario\g6e.mp3", "Sound\scenario\g6f.mp3", "Sound\scenario\g6g.mp3", "Sound\scenario\g6h.mp3", "Sound\scenario\g6i.mp3", "Sound\scenario\j1a.mp3", "Sound\scenario\j1b.mp3", "Sound\scenario\j1c.mp3", "Sound\scenario\j1d.mp3", "Sound\scenario\j1e.mp3", "Sound\scenario\j1f.mp3", "Sound\scenario\j1g.mp3", "Sound\scenario\j1h.mp3", "Sound\scenario\j1i.mp3", "Sound\scenario\j1j.mp3", "Sound\scenario\j1k.mp3", "Sound\scenario\j1l.mp3", "Sound\scenario\j1m.mp3", "Sound\scenario\j1n.mp3", "Sound\scenario\j1o.mp3", "Sound\scenario\j1p.mp3", "Sound\scenario\j1q.mp3", "Sound\scenario\j1r.mp3", "Sound\scenario\j1t.mp3", "Sound\scenario\j1u.mp3", "Sound\scenario\j1v.mp3", "Sound\scenario\j1w.mp3", "Sound\scenario\j1x.mp3", "Sound\scenario\j1y.mp3", "Sound\scenario\j1z.mp3", "Sound\scenario\j2a.mp3", "Sound\scenario\j2b.mp3", "Sound\scenario\j2c.mp3", "Sound\scenario\j2d.mp3", "Sound\scenario\j2e.mp3", "Sound\scenario\j2f.mp3", "Sound\scenario\j2g.mp3", "Sound\scenario\j2h.mp3", "Sound\scenario\j2i.mp3", "Sound\scenario\j2j.mp3", "Sound\scenario\j2k.mp3", "Sound\scenario\j2l.mp3", "Sound\scenario\j2m.mp3", "Sound\scenario\j2n.mp3", "Sound\scenario\j2o.mp3", "Sound\scenario\j3a.mp3", "Sound\scenario\j3b.mp3", "Sound\scenario\j3c.mp3", "Sound\scenario\j3d.mp3", "Sound\scenario\j3e.mp3", "Sound\scenario\j3f.mp3", "Sound\scenario\j3g.mp3", "Sound\scenario\j3h.mp3", "Sound\scenario\j3i.mp3", "Sound\scenario\j3j.mp3", "Sound\scenario\j3k.mp3", "Sound\scenario\j3l.mp3", "Sound\scenario\j3m.mp3", "Sound\scenario\j3n.mp3", "Sound\scenario\j3o.mp3", "Sound\scenario\j3p.mp3", "Sound\scenario\j4a.mp3", "Sound\scenario\j4b.mp3", "Sound\scenario\j4c.mp3", "Sound\scenario\j4c2.mp3", "Sound\scenario\j4d.mp3", "Sound\scenario\j4e.mp3", "Sound\scenario\j4f.mp3", "Sound\scenario\j4h.mp3", "Sound\scenario\j4i.mp3", "Sound\scenario\j4j.mp3", "Sound\scenario\j5a.mp3", "Sound\scenario\j5b.mp3", "Sound\scenario\j5c.mp3", "Sound\scenario\j5d.mp3", "Sound\scenario\j5e.mp3", "Sound\scenario\j5f.mp3", "Sound\scenario\j5g.mp3", "Sound\scenario\j5h.mp3", "Sound\scenario\j5i.mp3", "Sound\scenario\j5j.mp3", "Sound\scenario\j5k.mp3", "Sound\scenario\j5l.mp3", "Sound\scenario\j6a.mp3", "Sound\scenario\j6a2.mp3", "Sound\scenario\j6b.mp3", "Sound\scenario\j6c.mp3", "Sound\scenario\j6d.mp3", "Sound\scenario\j6e.mp3", "Sound\scenario\j6f.mp3", "Sound\scenario\j6g.mp3", "Sound\scenario\j6i.mp3", "Sound\scenario\j6j.mp3", "Sound\scenario\j6k.mp3", "Sound\scenario\j6l.mp3", "Sound\scenario\j6m.mp3", "Sound\scenario\j6n.mp3", "Sound\scenario\j6o.mp3", "Sound\scenario\j6q.mp3", "Sound\scenario\m1a.mp3", "Sound\scenario\m1b.mp3", "Sound\scenario\m1c.mp3", "Sound\scenario\m2a.mp3", "Sound\scenario\m2b.mp3", "Sound\scenario\m2c.mp3", "Sound\scenario\m2d.mp3", "Sound\scenario\m2e.mp3", "Sound\scenario\m2f.mp3", "Sound\scenario\m2g.mp3", "Sound\scenario\m2h.mp3", "Sound\scenario\m2i.mp3", "Sound\scenario\m2j.mp3", "Sound\scenario\m2k.mp3", "Sound\scenario\m2l.mp3", "Sound\scenario\m2m.mp3", "Sound\scenario\m2n.mp3", "Sound\scenario\m2o.mp3", "Sound\scenario\m2p.mp3", "Sound\scenario\m2q.mp3", "Sound\scenario\m3a.mp3", "Sound\scenario\m3b.mp3", "Sound\scenario\m3c.mp3", "Sound\scenario\m3d.mp3", "Sound\scenario\m3e.mp3", "Sound\scenario\m3f.mp3", "Sound\scenario\m3g.mp3", "Sound\scenario\m3h.mp3", "Sound\scenario\m3i.mp3", "Sound\scenario\m3j.mp3", "Sound\scenario\m4a.mp3", "Sound\scenario\M4B.mp3", "Sound\scenario\M4C.mp3", "Sound\scenario\m4d.mp3", "Sound\scenario\m4e.mp3", "Sound\scenario\m4f.mp3", "Sound\scenario\m4g.mp3", "Sound\scenario\m4h.mp3", "Sound\scenario\m4i.mp3", "Sound\scenario\m4j.mp3", "Sound\scenario\m4k.mp3", "Sound\scenario\m4m.mp3", "Sound\scenario\m5a.mp3", "Sound\scenario\m5b.mp3", "Sound\scenario\m5c.mp3", "Sound\scenario\m5d.mp3", "Sound\scenario\m5e.mp3", "Sound\scenario\m5f.mp3", "Sound\scenario\m5g.mp3", "Sound\scenario\m5h.mp3", "Sound\scenario\m6a.mp3", "Sound\scenario\m6b.mp3", "Sound\scenario\m6c.mp3", "Sound\scenario\m6d.mp3", "Sound\scenario\m6e.mp3", "Sound\scenario\m6f.mp3", "Sound\scenario\mc6.mp3", "Sound\scenario\S1a.mp3", "Sound\scenario\s1b.mp3", "Sound\scenario\s1c.mp3", "Sound\scenario\s1d.mp3", "Sound\scenario\s1e.mp3", "Sound\scenario\s1f.mp3", "Sound\scenario\s1g.mp3", "Sound\scenario\s1h.mp3", "Sound\scenario\s1i.mp3", "Sound\scenario\s1j.mp3", "Sound\scenario\s2a.mp3", "Sound\scenario\s2b.mp3", "Sound\scenario\s2c.mp3", "Sound\scenario\s2d.mp3", "Sound\scenario\s2e.mp3", "Sound\scenario\s2f.mp3", "Sound\scenario\s2g.mp3", "Sound\scenario\s2i.mp3", "Sound\scenario\s2j.mp3", "Sound\scenario\s2l.mp3", "Sound\scenario\s3a.mp3", "Sound\scenario\s3b.mp3", "Sound\scenario\s3c.mp3", "Sound\scenario\s3d.mp3", "Sound\scenario\s3e.mp3", "Sound\scenario\s3f.mp3", "Sound\scenario\s4a.mp3", "Sound\scenario\s4b.mp3", "Sound\scenario\s4c.mp3", "Sound\scenario\s4d.mp3", "Sound\scenario\s4e.mp3", "Sound\scenario\s4f.mp3", "Sound\scenario\s4g.mp3", "Sound\scenario\s4h.mp3", "Sound\scenario\s4i.mp3", "Sound\scenario\s4j.mp3", "Sound\scenario\s4k.mp3", "Sound\scenario\s4l.mp3", "Sound\scenario\s4m.mp3", "Sound\scenario\s5a.mp3", "Sound\scenario\s5b.mp3", "Sound\scenario\s5c.mp3", "Sound\scenario\s5d.mp3", "Sound\scenario\s6a.mp3", "Sound\scenario\s6b.mp3", "Sound\scenario\s6c.mp3", "Sound\scenario\s6d.mp3", "Sound\scenario\s6e.mp3", "Sound\scenario\s6f.mp3", "Sound\scenario\s6g.mp3", "Sound\scenario\s6h.mp3", "Sound\scenario\s6i.mp3", "Sound\scenario\w1a.mp3", "Sound\scenario\w1b.mp3", "Sound\scenario\w1c.mp3", "Sound\scenario\w1d.mp3", "Sound\scenario\w1e.mp3", "Sound\scenario\w1f.mp3", "Sound\scenario\w1g.mp3", "Sound\scenario\w1h.mp3", "Sound\scenario\w1i.mp3", "Sound\scenario\w1j.mp3", "Sound\scenario\w1k.mp3", "Sound\scenario\w1l.mp3", "Sound\scenario\w1m.mp3", "Sound\scenario\w1n.mp3", "Sound\scenario\w1o.mp3", "Sound\scenario\w1p.mp3", "Sound\scenario\w1q.mp3", "Sound\scenario\w1r.mp3", "Sound\scenario\w1s.mp3", "Sound\scenario\w1t.mp3", "Sound\scenario\w1wa.mp3", "Sound\scenario\w1wb.mp3", "Sound\scenario\w1wc.mp3", "Sound\scenario\w2a.mp3", "Sound\scenario\w2aa.mp3", "Sound\scenario\w2b.mp3", "Sound\scenario\w2c.mp3", "Sound\scenario\w2d.mp3", "Sound\scenario\w2e.mp3", "Sound\scenario\w2f.mp3", "Sound\scenario\w2g.mp3", "Sound\scenario\w2h.mp3", "Sound\scenario\w2i.mp3", "Sound\scenario\w2j.mp3", "Sound\scenario\w2k.mp3", "Sound\scenario\w2wa.mp3", "Sound\scenario\w3a.mp3", "Sound\scenario\w3b.mp3", "Sound\scenario\w3c.mp3", "Sound\scenario\w3d.mp3", "Sound\scenario\w3e.mp3", "Sound\scenario\w3e2.mp3", "Sound\scenario\w3f.mp3", "Sound\scenario\w3g.mp3", "Sound\scenario\w3h.mp3", "Sound\scenario\w3i.mp3", "Sound\scenario\w3j.mp3", "Sound\scenario\w3k.mp3", "Sound\scenario\w3l.mp3", "Sound\scenario\w3m.mp3", "Sound\scenario\w3n.mp3", "Sound\scenario\w3o.mp3", "Sound\scenario\w3wa.mp3", "Sound\scenario\w4a.mp3", "Sound\scenario\w4b.mp3", "Sound\scenario\w4c.mp3", "Sound\scenario\w4d.mp3", "Sound\scenario\w4e.mp3", "Sound\scenario\w4f.mp3", "Sound\scenario\w4g.mp3", "Sound\scenario\w4h.mp3", "Sound\scenario\w4i.mp3", "Sound\scenario\w4j.mp3", "Sound\scenario\w4k.mp3", "Sound\scenario\w4l.mp3", "Sound\scenario\w4m.mp3", "Sound\scenario\w4n.mp3", "Sound\scenario\w4o.mp3", "Sound\scenario\w4p.mp3", "Sound\scenario\w4q.mp3", "Sound\scenario\w4wa.mp3", "Sound\scenario\w4wb.mp3", "Sound\scenario\w4wc.mp3", "Sound\scenario\w5a.mp3", "Sound\scenario\w5a2.mp3", "Sound\scenario\w5b.mp3", "Sound\scenario\w5c.mp3", "Sound\scenario\w5d.mp3", "Sound\scenario\w5e.mp3", "Sound\scenario\w5f.mp3", "Sound\scenario\w5g.mp3", "Sound\scenario\w5h.mp3", "Sound\scenario\w5i.mp3", "Sound\scenario\w5j.mp3", "Sound\scenario\w5k.mp3", "Sound\scenario\w5l.mp3", "Sound\scenario\w5m.mp3", "Sound\scenario\w5n.mp3", "Sound\scenario\w5o.mp3", "Sound\scenario\w5p.mp3", "Sound\scenario\w5q.mp3", "Sound\scenario\w5r.mp3", "Sound\scenario\w5s.mp3", "Sound\scenario\w5t.mp3", "Sound\scenario\w5u.mp3", "Sound\scenario\w5v.mp3", "Sound\scenario\w5w.mp3", "Sound\scenario\w5wa.mp3", "Sound\scenario\w5wd.mp3", "Sound\scenario\w5we.mp3", "Sound\scenario\w5wf.mp3", "Sound\scenario\w5wg.mp3", "Sound\scenario\w5wh.mp3", "Sound\scenario\w5x.mp3", "Sound\scenario\w5y.mp3", "Sound\scenario\w5z.mp3", "Sound\scenario\w5z2.mp3", "Sound\scenario\w5z3.mp3", "Sound\scenario\w5z4.mp3", "Sound\scenario\w6a.mp3", "Sound\scenario\w6b.mp3", "Sound\scenario\w6c.mp3", "Sound\scenario\w6d.mp3", "Sound\scenario\w6e.mp3", "Sound\scenario\w6f.mp3", "Sound\scenario\w6g.mp3", "Sound\scenario\w6h.mp3", "Sound\scenario\w6i.mp3", "Sound\scenario\w6j.mp3", "Sound\scenario\w6k.mp3", "Sound\scenario\w6l.mp3", "Sound\scenario\w6m.mp3", "Sound\scenario\w6n.mp3", "Sound\scenario\w6o.mp3", "Sound\scenario\w6p.mp3", "Sound\scenario\w6q.mp3", "Sound\scenario\w6r.mp3", "Sound\scenario\w6s.mp3", "Sound\scenario\w6t.mp3", "Sound\scenario\w6u.mp3", "Sound\scenario\w6v.mp3", "Sound\scenario\w6w.mp3", "Sound\scenario\w7a.mp3", "Sound\scenario\w7b.mp3", "Sound\scenario\w7c.mp3", "Sound\scenario\w7d.mp3", "Sound\scenario\w7e.mp3", "Sound\scenario\w7f.mp3", "Sound\scenario\w7g.mp3", "Sound\scenario\w7h.mp3", "Sound\scenario\w7i.mp3", "Sound\scenario\w7j.mp3", "Sound\scenario\w7k.mp3", "Sound\scenario\w7l.mp3", "Sound\scenario\w7m.mp3", "Sound\scenario\w7n.mp3", "Sound\scenario\w7o.mp3", "Sound\scenario\w7p.mp3", "Sound\scenario\w7q.mp3", "Sound\scenario\Wolf.mp3", "Sound\stream\Aztecs.mp3", "Sound\stream\British.mp3", "Sound\stream\Byzantin.mp3", "Sound\stream\Celt.mp3", "Sound\stream\Chinese.mp3", "Sound\stream\Countdwn.mp3", "Sound\stream\credits.mp3", "Sound\stream\French.mp3", "Sound\stream\Goth.mp3", "Sound\stream\Huns.mp3", "Sound\stream\Japanese.mp3", "Sound\stream\Koreans.mp3", "Sound\stream\lost.mp3", "Sound\stream\Mayans.mp3", "Sound\stream\Mongol.mp3", "Sound\stream\open.mp3", "Sound\stream\Persian.mp3", "Sound\stream\Random.mp3", "Sound\stream\Saracen.mp3", "Sound\stream\Spanish.mp3", "Sound\stream\Teuton.mp3", "Sound\stream\town.mp3", "Sound\stream\Turk.mp3", "Sound\stream\Viking.mp3", "Sound\stream\won1.mp3", "Sound\stream\won2.mp3", "Sound\stream\xcredits.mp3", "Sound\stream\xopen.mp3", "Sound\stream\xtown.mp3", "Sound\terrain\Cricket.wav", "Sound\terrain\jungle1.wav", "Sound\terrain\jungle2.wav", "Sound\terrain\jungle3.wav", "Sound\terrain\jungle4.wav", "Sound\terrain\tf1.wav", "Sound\terrain\tf2.wav", "Sound\terrain\tf3.wav", "Sound\terrain\tf4.wav", "Sound\terrain\tf6.wav", "Sound\terrain\tf7.wav", "Sound\terrain\tf8.wav", "Sound\terrain\Wave1.wav", "Sound\terrain\Wave2.wav", "Sound\terrain\Wave3.wav", "Sound\terrain\Wave4.wav", "Sound\terrain\Wave5.wav", "Sound\terrain\Wind1.wav", "Sound\terrain\Wind2.wav", "Sound\terrain\Wind3.wav", "Support\Support.txt", "Support\The Conquerors - MFill.lnk", "Support\The Conquerors - MSync.lnk", "Support\The Conquerors - NoMusic.lnk", "Support\The Conquerors - NormalMouse.lnk", "Support\The Conquerors - NoSC.lnk", "Support\The Conquerors - NoSound.lnk", "Support\The Conquerors - NoStartup.lnk", "Support\The Conquerors - NoTerrainSound.lnk", "Taunt\01 Yes.mp3", "Taunt\02 No.mp3", "Taunt\03 Food, please.mp3", "Taunt\04 Wood, please.mp3", "Taunt\05 Gold, please.mp3", "Taunt\06 Stone, please.mp3", "Taunt\07 Ahh.mp3", "Taunt\08 All hail.mp3", "Taunt\09 Oooh.mp3", "Taunt\10 Back to Age 1.mp3", "Taunt\11 Herb laugh.mp3", "Taunt\12 Being rushed.mp3", "Taunt\13 Blame your isp.mp3", "Taunt\14 Start the game.mp3", "Taunt\15 Don't Point That Thing.mp3", "Taunt\16 Enemy Sighted.mp3", "Taunt\17 It Is Good.mp3", "Taunt\18 I Need a Monk.mp3", "Taunt\19 Long Time No Siege.mp3", "Taunt\20 My granny.mp3", "Taunt\21 Nice Town I'll Take It.mp3", "Taunt\22 Quit Touchin.mp3", "Taunt\23 Raiding Party.mp3", "Taunt\24 Dadgum.mp3", "Taunt\25 Smite Me.mp3", "Taunt\26 The wonder.mp3", "Taunt\27 You play 2 hours.mp3", "Taunt\28 You Should See the Other Guy.mp3", "Taunt\29 Roggan.mp3", "Taunt\30 Wololo.mp3", "Taunt\31 Attack an Enemy Now.mp3", "Taunt\32 Cease Creating Extra Villagers.mp3", "Taunt\33 Create Extra Villagers.mp3", "Taunt\34 Build a Navy.mp3", "Taunt\35 Stop Building a Navy.mp3", "Taunt\36 Wait for My Signal to Attack.mp3", "Taunt\37 Build a Wonder.mp3", "Taunt\38 Give Me Your Extra Resources.mp3", "Taunt\39 Ally.mp3", "Taunt\40 Enemy.mp3", "Taunt\41 Neutral.mp3", "Taunt\42 What Age Are You In.mp3"]
	For File in GameFiles {
		If FileExist(Location '\' File) {
			++Similarity
		}
	}
	Similarity := Similarity / GameFiles.Length
	Return Similarity > 0.2
}
DownloadA(Link, File) {
	WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("HEAD", Link)
	WebRequest.Send()
	Size := WebRequest.GetResponseHeader("Content-Length")
	Size //= (1024 * 1024)
	PB.Value := 0
	PB.Opt('Range1-' Size)
	SetTimer(WatchDownload, 1000)
	Download(Link, File)
	WatchDownload() {
		PB.Value := FileGetSize(File, 'M')
	}
	PB.Value := Size
	SetTimer(WatchDownload, 0)
}
ListHashs(Dir, HashType := 2) {
	Hashs := 'Map('
	Loop Files, Dir '\*.*', 'R' {
		Path := StrReplace(A_LoopFileFullPath, Dir '\',,,, 1)
		Hashs .= ' "' Path '", "' HashFile(A_LoopFileFullPath, HashType) '"`n,'
	}
	Hashs .= ')'
	Return Hashs
}

; HashFile by Deo
; https://autohotkey.com/board/topic/66139-ahk-l-calculating-md5sha-checksum-from-file/
; Modified for AutoHotkey v2 by lexikos.
/*
HASH types:
1 - MD2
2 - MD5
3 - SHA
4 - SHA256
5 - SHA384
6 - SHA512
*/
HashFile(filePath, hashType := 2) {
	static PROV_RSA_AES := 24
	static CRYPT_VERIFYCONTEXT := 0xF0000000
	static BUFF_SIZE := 1024 * 1024 ; 1 MB
	static HP_HASHVAL := 0x0002
	static HP_HASHSIZE := 0x0004

	switch hashType {
		case 1: hash_alg := (CALG_MD2 := 32769)
		case 2: hash_alg := (CALG_MD5 := 32771)
		case 3: hash_alg := (CALG_SHA := 32772)
		case 4: hash_alg := (CALG_SHA_256 := 32780)
		case 5: hash_alg := (CALG_SHA_384 := 32781)
		case 6: hash_alg := (CALG_SHA_512 := 32782)
		default: throw ValueError('Invalid hashType', -1, hashType)
	}

	Try {
		f := FileOpen(filePath, "r")
		f.Pos := 0 ; Rewind in case of BOM.
	} Catch 
		throw(filePath)

	HCRYPTPROV() => {
		ptr: 0,
		__delete: this => this.ptr && DllCall("Advapi32\CryptReleaseContext", "Ptr", this, "UInt", 0)
	}

	if !DllCall("Advapi32\CryptAcquireContextW"
		, "Ptr*", hProv := HCRYPTPROV()
		, "Uint", 0
		, "Uint", 0
		, "Uint", PROV_RSA_AES
		, "UInt", CRYPT_VERIFYCONTEXT)
		throw OSError()

	HCRYPTHASH() => {
		ptr: 0,
		__delete: this => this.ptr && DllCall("Advapi32\CryptDestroyHash", "Ptr", this)
	}

	if !DllCall("Advapi32\CryptCreateHash"
		, "Ptr", hProv
		, "Uint", hash_alg
		, "Uint", 0
		, "Uint", 0
		, "Ptr*", hHash := HCRYPTHASH())
		throw OSError()

	read_buf := Buffer(BUFF_SIZE, 0)

	While (cbCount := f.RawRead(read_buf, BUFF_SIZE))
	{
		if !DllCall("Advapi32\CryptHashData"
			, "Ptr", hHash
			, "Ptr", read_buf
			, "Uint", cbCount
			, "Uint", 0)
			throw OSError()
	}

	if !DllCall("Advapi32\CryptGetHashParam"
		, "Ptr", hHash
		, "Uint", HP_HASHSIZE
		, "Uint*", &HashLen := 0
		, "Uint*", &HashLenSize := 4
		, "UInt", 0)
		throw OSError()

	bHash := Buffer(HashLen, 0)
	if !DllCall("Advapi32\CryptGetHashParam"
		, "Ptr", hHash
		, "Uint", HP_HASHVAL
		, "Ptr", bHash
		, "Uint*", &HashLen
		, "UInt", 0)
		throw OSError()

	loop HashLen
		HashVal .= Format('{:02x}', (NumGet(bHash, A_Index - 1, "UChar")) & 0xff)

	return HashVal
}
; ======================================================================================================================
; Name:              CreateImageButton()
; Function:          Create images and assign them to pushbuttons.
; Tested with:       AHK 2.0.11 (U32/U64)
; Tested on:         Win 10 (x64)
; Change history:    1.0.01/2024-01-01/just me   - Use Gui.Backcolor as default for the background if available
;                    1.0.00/2023-02-03/just me   - Initial stable release for AHK v2
; Credits:           THX tic for GDIP.AHK, tkoi for ILBUTTON.AHK
; ======================================================================================================================
; How to use:
;     1. Call UseGDIP() to initialize the Gdiplus.dll before the first call of this function.
;     2. Create a push button (e.g. "MyGui.AddButton("option", "caption").
;     3. If you want to want to use another color than the GUI's current Backcolor for the background of the images
;        - especially for rounded buttons - call CreateImageButton("SetDefGuiColor", NewColor) where NewColor is a RGB
;        integer value (0xRRGGBB) or a HTML color name ("Red"). You can also change the default text color by calling
;        CreateImageButton("SetDefTxtColor", NewColor).
;        To reset the colors to the AHK/system default pass "*DEF*" in NewColor, to reset the background to use
;        Gui.Backcolor pass "*GUI*".
;     4. To create an image button call CreateImageButton() passing two or more parameters:
;        GuiBtn      -  Gui.Button object.
;        Mode        -  The mode used to create the bitmaps:
;                       0  -  unicolored or bitmap
;                       1  -  vertical bicolored
;                       2  -  horizontal bicolored
;                       3  -  vertical gradient
;                       4  -  horizontal gradient
;                       5  -  vertical gradient using StartColor at both borders and TargetColor at the center
;                       6  -  horizontal gradient using StartColor at both borders and TargetColor at the center
;                       7  -  'raised' style
;                       8  -  forward diagonal gradient from the upper-left corner to the lower-right corner
;                       9  -  backward diagonal gradient from the upper-right corner to the lower-left corner
;                      -1  -  reset the button
;        Options*    -  variadic array containing up to 6 option arrays (see below).
;        ---------------------------------------------------------------------------------------------------------------
;        The index of each option object determines the corresponding button state on which the bitmap will be shown.
;        MSDN defines 6 states (http://msdn.microsoft.com/en-us/windows/bb775975):
;           PBS_NORMAL    = 1
;	         PBS_HOT       = 2
;	         PBS_PRESSED   = 3
;	         PBS_DISABLED  = 4
;	         PBS_DEFAULTED = 5
;	         PBS_STYLUSHOT = 6 <- used only on tablet computers (that's false for Windows Vista and 7, see below)
;        If you don't want the button to be 'animated' on themed GUIs, just pass one option object with index 1.
;        On Windows Vista and 7 themed bottons are 'animated' using the images of states 5 and 6 after clicked.
;        ---------------------------------------------------------------------------------------------------------------
;        Each option array may contain the following values:
;           Index Value
;           1     StartColor  mandatory for Option[1], higher indices will inherit the value of Option[1], if omitted:
;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
;                             -  Path of an image file or HBITMAP handle for mode 0.
;           2     TargetColor mandatory for Option[1] if Mode > 0. Higher indcices will inherit the color of Option[1],
;                             if omitted:
;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
;                             -  String "HICON" if StartColor contains a HICON handle.
;           3     TextColor   optional, if omitted, the default text color will be used for Option[1], higher indices
;                             will inherit the color of Option[1]:
;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
;                                Default: 0xFF000000 (black)
;           4     Rounded     optional:
;                             -  Radius of the rounded corners in pixel; the letters 'H' and 'W' may be specified
;                                also to use the half of the button's height or width respectively.
;                                Default: 0 - not rounded
;           5     BorderColor optional, ignored for modes 0 (bitmap) and 7, color of the border:
;                             -  RGB integer value (0xRRGGBB) or HTML color name ("Red").
;           6     BorderWidth optional, ignored for modes 0 (bitmap) and 7, width of the border in pixels:
;                             -  Default: 1
;        ---------------------------------------------------------------------------------------------------------------
;        If the the button has a caption it will be drawn upon the bitmaps.
;     5. Call GdiplusShutDown() to clean up the resources used by GDI+ after the last function call or
;        before the script terminates.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; CreateImageButton()
; ======================================================================================================================
CreateImageButton(GuiBtn, Mode, Options*) {
    ; Default colors - COLOR_3DFACE is used by AHK as default Gui background color
    Static DefGuiColor := SetDefGuiColor("*GUI*"),
        DefTxtColor := SetDefTxtColor("*DEF*"),
        GammaCorr := False
    Static HTML := { BLACK: 0x000000, GRAY: 0x808080, SILVER: 0xC0C0C0, WHITE: 0xFFFFFF,
        MAROON: 0x800000, PURPLE: 0x800080, FUCHSIA: 0xFF00FF, RED: 0xFF0000,
        GREEN: 0x008000, OLIVE: 0x808000, YELLOW: 0xFFFF00, LIME: 0x00FF00,
        NAVY: 0x000080, TEAL: 0x008080, AQUA: 0x00FFFF, BLUE: 0x0000FF }
    Static MaxBitmaps := 6, MaxOptions := 6
    Static BitMaps := [], Buttons := Map()
    Static Bitmap := 0, Graphics := 0, Font := 0, StringFormat := 0, HIML := 0
    Static BtnCaption := "", BtnStyle := 0
    Static HWND := 0
    Bitmap := Graphics := Font := StringFormat := HIML := 0
    NumBitmaps := 0
    BtnCaption := ""
    BtnStyle := 0
    BtnW := 0
    BtnH := 0
    GuiColor := ""
    TxtColor := ""
    HWND := 0
    ; -------------------------------------------------------------------------------------------------------------------
    ; Check for 'special calls'
    If !IsObject(GuiBtn) {
        Switch GuiBtn {
            Case "SetDefGuiColor":
                DefGuiColor := SetDefGuiColor(Mode)
                Return True
            Case "SetDefTxtColor":
                DefTxtColor := SetDefTxtColor(Mode)
                Return True
            Case "SetGammaCorrection":
                GammaCorr := !!Mode
                Return True
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; Check the control object
    If (Type(GuiBtn) != "Gui.Button")
        Return ErrorExit("Invalid parameter GuiBtn!")
    HWND := GuiBtn.Hwnd
    ; -------------------------------------------------------------------------------------------------------------------
    ; Check Mode
    If !IsInteger(Mode) || (Mode < -1) || (Mode > 9)
        Return ErrorExit("Invalid parameter Mode!")
    If (Mode = -1) { ; reset the button
        If Buttons.Has(HWND) {
            Btn := Buttons[HWND]
            BIL := Buffer(20 + A_PtrSize, 0)
            NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
            SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
            IL_Destroy(Btn["HIML"])
            ControlSetStyle(Btn["Style"], HWND)
            Buttons.Delete(HWND)
            Return True
        }
        Return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; Check Options
    If !(Options Is Array) || !Options.Has(1) || (Options.Length > MaxOptions)
        Return ErrorExit("Invalid parameter Options!")
    ; -------------------------------------------------------------------------------------------------------------------
    HBITMAP := HFORMAT := PBITMAP := PBRUSH := PFONT := PGRAPHICS := PPATH := 0
    ; -------------------------------------------------------------------------------------------------------------------
    ; Get control's styles
    BtnStyle := ControlGetStyle(HWND)
    ; -------------------------------------------------------------------------------------------------------------------
    ; Get the button's font
    PFONT := 0
    If (HFONT := SendMessage(0x31, 0, 0, HWND)) { ; WM_GETFONT
        DC := DllCall("GetDC", "Ptr", HWND, "Ptr")
        DllCall("SelectObject", "Ptr", DC, "Ptr", HFONT)
        DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", DC, "PtrP", &PFONT)
        DllCall("ReleaseDC", "Ptr", HWND, "Ptr", DC)
    }
    If !(Font := PFONT)
        Return ErrorExit("Couldn't get button's font!")
    ; -------------------------------------------------------------------------------------------------------------------
    ; Get the button's width and height
    ControlGetPos(, , &BtnW, &BtnH, HWND)
    ; -------------------------------------------------------------------------------------------------------------------
    ; Get the button's caption
    BtnCaption := GuiBtn.Text
    ; -------------------------------------------------------------------------------------------------------------------
    ; Create a GDI+ bitmap
    PBITMAP := 0
    DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0",
        "Int", BtnW, "Int", BtnH, "Int", 0, "UInt", 0x26200A, "Ptr", 0, "PtrP", &PBITMAP)
    If !(Bitmap := PBITMAP)
        Return ErrorExit("Couldn't create the GDI+ bitmap!")
    ; Get the pointer to its graphics
    PGRAPHICS := 0
    DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", PBITMAP, "PtrP", &PGRAPHICS)
    If !(Graphics := PGRAPHICS)
        Return ErrorExit("Couldn't get the the GDI+ bitmap's graphics!")
    ; Quality settings
    DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", PGRAPHICS, "UInt", 4)
    DllCall("Gdiplus.dll\GdipSetInterpolationMode", "Ptr", PGRAPHICS, "Int", 7)
    DllCall("Gdiplus.dll\GdipSetCompositingQuality", "Ptr", PGRAPHICS, "UInt", 4)
    DllCall("Gdiplus.dll\GdipSetRenderingOrigin", "Ptr", PGRAPHICS, "Int", 0, "Int", 0)
    DllCall("Gdiplus.dll\GdipSetPixelOffsetMode", "Ptr", PGRAPHICS, "UInt", 4)
    DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", PGRAPHICS, "Int", 0)
    ; Create a StringFormat object
    HFORMAT := 0
    DllCall("Gdiplus.dll\GdipStringFormatGetGenericTypographic", "PtrP", &HFORMAT)
    ; Horizontal alignment
    ; BS_LEFT = 0x0100, BS_RIGHT = 0x0200, BS_CENTER = 0x0300, BS_TOP = 0x0400, BS_BOTTOM = 0x0800, BS_VCENTER = 0x0C00
    ; SA_LEFT = 0, SA_CENTER = 1, SA_RIGHT = 2
    HALIGN := (BtnStyle & 0x0300) = 0x0300 ? 1
        : (BtnStyle & 0x0300) = 0x0200 ? 2
            : (BtnStyle & 0x0300) = 0x0100 ? 0
            : 1
    DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", HFORMAT, "Int", HALIGN)
    ; Vertical alignment
    VALIGN := (BtnStyle & 0x0C00) = 0x0400 ? 0
        : (BtnStyle & 0x0C00) = 0x0800 ? 2
            : 1
    DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", HFORMAT, "Int", VALIGN)
    DllCall("Gdiplus.dll\GdipSetStringFormatHotkeyPrefix", "Ptr", HFORMAT, "UInt", 1) ; THX robodesign
    StringFormat := HFORMAT
    ; -------------------------------------------------------------------------------------------------------------------
    ; Create the bitmap(s)
    BitMaps := []
    BitMaps.Length := MaxBitmaps
    Opt1 := Options[1]
    Opt1.Length := MaxOptions
    Loop MaxOptions
        If !Opt1.Has(A_Index)
            Opt1[A_Index] := ""
    If (Opt1[3] = "")
        Opt1[3] := GetARGB(DefTxtColor)
    For Idx, Opt In Options {
        If !IsSet(Opt) || !IsObject(Opt) || !(Opt Is Array)
            Continue
        BkgColor1 := BkgColor2 := TxtColor := Rounded := GuiColor := Image := ""
        ; Replace omitted options with the values of Options.1
        If (Idx > 1) {
            Opt.Length := MaxOptions
            Loop MaxOptions {
                If !Opt.Has(A_Index) || (Opt[A_Index] = "")
                    Opt[A_Index] := Opt1[A_Index]
            }
        }
        ; ----------------------------------------------------------------------------------------------------------------
        ; Check option values
        ; StartColor & TargetColor
        If (Mode = 0) && BitmapOrIcon(Opt[1], Opt[2])
            Image := Opt[1]
        Else {
            If !IsInteger(Opt[1]) && !HTML.HasOwnProp(Opt[1])
                Return ErrorExit("Invalid value for StartColor in Options[" . Idx . "]!")
            BkgColor1 := GetARGB(Opt[1])
            If (Opt[2] = "")
                Opt[2] := Opt[1]
            If !IsInteger(Opt[2]) && !HTML.HasOwnProp(Opt[2])
                Return ErrorExit("Invalid value for TargetColor in Options[" . Idx . "]!")
            BkgColor2 := GetARGB(Opt[2])
        }
        ; TextColor
        If (Opt[3] = "")
            Opt[3] := GetARGB(DefTxtColor)
        If !IsInteger(Opt[3]) && !HTML.HasOwnProp(Opt[3])
            Return ErrorExit("Invalid value for TxtColor in Options[" . Idx . "]!")
        TxtColor := GetARGB(Opt[3])
        ; Rounded
        Rounded := Opt[4]
        If (Rounded = "H")
            Rounded := BtnH * 0.5
        If (Rounded = "W")
            Rounded := BtnW * 0.5
        If !IsNumber(Rounded)
            Rounded := 0
        ; GuiColor
        If DefGuiColor = "*GUI*"
            GuiColor := GetARGB(GuiBtn.Gui.Backcolor != "" ? "0x" GuiBtn.Gui.Backcolor : SetDefGuiColor("*DEF*"))
        Else
            GuiColor := GetARGB(DefGuiColor)
        ; BorderColor
        BorderColor := ""
        If (Opt[5] != "") {
            If !IsInteger(Opt[5]) && !HTML.HasOwnProp(Opt[5])
                Return ErrorExit("Invalid value for BorderColor in Options[" . Idx . "]!")
            BorderColor := 0xFF000000 | GetARGB(Opt[5]) ; BorderColor must be always opaque
        }
        ; BorderWidth
        BorderWidth := Opt[6] ? Opt[6] : 1
        ; ----------------------------------------------------------------------------------------------------------------
        ; Clear the background
        DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", PGRAPHICS, "UInt", GuiColor)
        ; Create the image
        If (Image = "") { ; Create a BitMap based on the specified colors
            PathX := PathY := 0, PathW := BtnW, PathH := BtnH
            ; Create a GraphicsPath
            PPATH := 0
            DllCall("Gdiplus.dll\GdipCreatePath", "UInt", 0, "PtrP", &PPATH)
            If (Rounded < 1) ; the path is a rectangular rectangle
                PathAddRectangle(PPATH, PathX, PathY, PathW, PathH)
            Else ; the path is a rounded rectangle
                PathAddRoundedRect(PPATH, PathX, PathY, PathW, PathH, Rounded)
            ; If BorderColor and BorderWidth are specified, 'draw' the border (not for Mode 7)
            If (BorderColor != "") && (BorderWidth > 0) && (Mode != 7) {
                ; Create a SolidBrush
                PBRUSH := 0
                DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", BorderColor, "PtrP", &PBRUSH)
                ; Fill the path
                DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                ; Free the brush
                DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
                ; Reset the path
                DllCall("Gdiplus.dll\GdipResetPath", "Ptr", PPATH)
                ; Add a new 'inner' path
                PathX := PathY := BorderWidth, PathW -= BorderWidth, PathH -= BorderWidth, Rounded -= BorderWidth
                If (Rounded < 1) ; the path is a rectangular rectangle
                    PathAddRectangle(PPATH, PathX, PathY, PathW - PathX, PathH - PathY)
                Else ; the path is a rounded rectangle
                    PathAddRoundedRect(PPATH, PathX, PathY, PathW, PathH, Rounded)
                ; If a BorderColor has been drawn, BkgColors must be opaque
                BkgColor1 := 0xFF000000 | BkgColor1
                BkgColor2 := 0xFF000000 | BkgColor2
            }
            PathW -= PathX
            PathH -= PathY
            PBRUSH := 0
            RECTF := 0
            Switch Mode {
                Case 0:                    ; the background is unicolored
                    ; Create a SolidBrush
                    DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", BkgColor1, "PtrP", &PBRUSH)
                    ; Fill the path
                    DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                Case 1, 2:                 ; the background is bicolored
                    ; Create a LineGradientBrush
                    SetRectF(&RECTF, PathX, PathY, PathW, PathH)
                    DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect",
                        "Ptr", RECTF, "UInt", BkgColor1, "UInt", BkgColor2, "Int", Mode & 1, "Int", 3, "PtrP", &PBRUSH)
                    DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", PBRUSH, "Int", GammaCorr)
                    ; Set up colors and positions
                    SetRect(&COLORS, BkgColor1, BkgColor1, BkgColor2, BkgColor2) ; sorry for function misuse
                    SetRectF(&POSITIONS, 0, 0.5, 0.5, 1) ; sorry for function misuse
                    DllCall("Gdiplus.dll\GdipSetLinePresetBlend",
                        "Ptr", PBRUSH, "Ptr", COLORS, "Ptr", POSITIONS, "Int", 4)
                    ; Fill the path
                    DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                Case 3, 4, 5, 6, 8, 9:     ; the background is a gradient
                    ; Determine the brush's width/height
                    W := Mode = 6 ? PathW / 2 : PathW  ; horizontal
                    H := Mode = 5 ? PathH / 2 : PathH  ; vertical
                    ; Create a LineGradientBrush
                    SetRectF(&RECTF, PathX, PathY, W, H)
                    LGM := Mode > 6 ? Mode - 6 : Mode & 1 ; LinearGradientMode
                    DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect",
                        "Ptr", RECTF, "UInt", BkgColor1, "UInt", BkgColor2, "Int", LGM, "Int", 3, "PtrP", &PBRUSH)
                    DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", PBRUSH, "Int", GammaCorr)
                    ; Fill the path
                    DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                Case 7:                    ; raised mode
                    DllCall("Gdiplus.dll\GdipCreatePathGradientFromPath", "Ptr", PPATH, "PtrP", &PBRUSH)
                    ; Set Gamma Correction
                    DllCall("Gdiplus.dll\GdipSetPathGradientGammaCorrection", "Ptr", PBRUSH, "UInt", GammaCorr)
                    ; Set surround and center colors
                    ColorArray := Buffer(4, 0)
                    NumPut("UInt", BkgColor1, ColorArray)
                    DllCall("Gdiplus.dll\GdipSetPathGradientSurroundColorsWithCount",
                        "Ptr", PBRUSH, "Ptr", ColorArray, "IntP", 1)
                    DllCall("Gdiplus.dll\GdipSetPathGradientCenterColor", "Ptr", PBRUSH, "UInt", BkgColor2)
                    ; Set the FocusScales
                    FS := (BtnH < BtnW ? BtnH : BtnW) / 3
                    XScale := (BtnW - FS) / BtnW
                    YScale := (BtnH - FS) / BtnH
                    DllCall("Gdiplus.dll\GdipSetPathGradientFocusScales", "Ptr", PBRUSH, "Float", XScale, "Float", YScale)
                    ; Fill the path
                    DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
            }
            ; Free resources
            DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
            DllCall("Gdiplus.dll\GdipDeletePath", "Ptr", PPATH)
        }
        Else { ; Create a bitmap from HBITMAP or file
            PBM := 0
            If IsInteger(Image)
                If (Opt[2] = "HICON")
                    DllCall("Gdiplus.dll\GdipCreateBitmapFromHICON", "Ptr", Image, "PtrP", &PBM)
                Else
                    DllCall("Gdiplus.dll\GdipCreateBitmapFromHBITMAP", "Ptr", Image, "Ptr", 0, "PtrP", &PBM)
            Else
                DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", Image, "PtrP", &PBM)
            ; Draw the bitmap
            DllCall("Gdiplus.dll\GdipDrawImageRectI",
                "Ptr", PGRAPHICS, "Ptr", PBM, "Int", 0, "Int", 0, "Int", BtnW, "Int", BtnH)
            ; Free the bitmap
            DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBM)
        }
        ; ----------------------------------------------------------------------------------------------------------------
        ; Draw the caption
        If (BtnCaption != "") {
            ; Text color
            DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", TxtColor, "PtrP", &PBRUSH)
            ; Set the text's rectangle
            RECT := Buffer(16, 0)
            NumPut("Float", BtnW, "Float", BtnH, RECT, 8)
            ; Draw the text
            DllCall("Gdiplus.dll\GdipDrawString",
                "Ptr", PGRAPHICS, "Str", BtnCaption, "Int", -1,
                "Ptr", PFONT, "Ptr", RECT, "Ptr", HFORMAT, "Ptr", PBRUSH)
        }
        ; ----------------------------------------------------------------------------------------------------------------
        ; Create a HBITMAP handle from the bitmap and add it to the array
        HBITMAP := 0
        DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", PBITMAP, "PtrP", &HBITMAP, "UInt", 0X00FFFFFF)
        BitMaps[Idx] := HBITMAP
        NumBitmaps++
        ; Free resources
        DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
    }
    ; Now free remaining the GDI+ objects
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBITMAP)
    DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", PGRAPHICS)
    DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", PFONT)
    DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", HFORMAT)
    Bitmap := Graphics := Font := StringFormat := 0
    ; -------------------------------------------------------------------------------------------------------------------
    ; Create the ImageList
    ; ILC_COLOR32 = 0x20
    HIL := DllCall("Comctl32.dll\ImageList_Create"
        , "UInt", BtnW, "UInt", BtnH, "UInt", 0x20, "Int", 6, "Int", 0, "Ptr") ; ILC_COLOR32
    Loop (NumBitmaps > 1) ? MaxBitmaps : 1 {
        HBITMAP := BitMaps.Has(A_Index) ? BitMaps[A_Index] : BitMaps[1]
        DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", HBITMAP, "Ptr", 0)
    }
    ; Create a BUTTON_IMAGELIST structure
    BIL := Buffer(20 + A_PtrSize, 0)
    ; Get the currently assigned image list
    SendMessage(0x1603, 0, BIL.Ptr, HWND) ; BCM_GETIMAGELIST
    PrevIL := NumGet(BIL, "UPtr")
    ; Remove the previous image list, if any
    BIL := Buffer(20 + A_PtrSize, 0)
    NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
    SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
    ; Create a new BUTTON_IMAGELIST structure
    ; BUTTON_IMAGELIST_ALIGN_LEFT = 0, BUTTON_IMAGELIST_ALIGN_RIGHT = 1, BUTTON_IMAGELIST_ALIGN_CENTER = 4,
    BIL := Buffer(20 + A_PtrSize, 0)
    NumPut("Ptr", HIL, BIL)
    Numput("UInt", 4, BIL, A_PtrSize + 16) ; BUTTON_IMAGELIST_ALIGN_CENTER
    ControlSetStyle(BtnStyle | 0x0080, HWND) ; BS_BITMAP
    ; Remove the currently assigned image list, if any
    If (PrevIL)
        IL_Destroy(PrevIL)
    ; Assign the ImageList to the button
    SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
    ; Free the bitmaps
    FreeBitmaps()
    NumBitmaps := 0
    ; -------------------------------------------------------------------------------------------------------------------
    ; All done successfully
    Buttons[HWND] := Map("HIML", HIL, "Style", BtnStyle)
    Return True
    ; ===================================================================================================================
    ; Internally used functions
    ; ===================================================================================================================
    ; Set the default GUI color.
    ; GuiColor - RGB integer value (0xRRGGBB) or HTML color name ("Red").
    ;          - "*GUI*" to use Gui.Backcolor (default)
    ;          - "*DEF*" to use AHK's default Gui color.
    SetDefGuiColor(GuiColor) {
        Static DefColor := DllCall("GetSysColor", "Int", 15, "UInt") ; COLOR_3DFACE
        Switch
        {
            Case (GuiColor = "*GUI*"):
                Return GuiColor
            Case (GuiColor = "*DEF*"):
                Return GetRGB(DefColor)
            Case IsInteger(GuiColor):
                Return GuiColor & 0xFFFFFF
            Case HTML.HasOwnProp(GuiColor):
                Return HTML.%GuiColor% &0xFFFFFF
            Default:
                Throw ValueError("Parameter GuiColor invalid", -1, GuiColor)
        }
    }
    ; ===================================================================================================================
    ; Set the default text color.
    ; TxtColor - RGB integer value (0xRRGGBB) or HTML color name ("Red").
    ;          - "*DEF*" to reset to AHK's default text color.
    SetDefTxtColor(TxtColor) {
        Static DefColor := DllCall("GetSysColor", "Int", 18, "UInt") ; COLOR_BTNTEXT
        Switch
        {
            Case (TxtColor = "*DEF*"):
                Return GetRGB(DefColor)
            Case IsInteger(TxtColor):
                Return TxtColor & 0xFFFFFF
            Case HTML.HasOwnProp(TxtColor):
                Return HTML.%TxtColor% &0xFFFFFF
            Default:
                Throw ValueError("Parameter TxtColor invalid", -1, TxtColor)
        }
        Return True
    }
    ; ===================================================================================================================
    ; PRIVATE FUNCTIONS =================================================================================================
    ; ===================================================================================================================
    BitmapOrIcon(O1, O2) {
        ; OBJ_BITMAP = 7
        Return IsInteger(O1) ? (O2 = "HICON") || (DllCall("GetObjectType", "Ptr", O1, "UInt") = 7) : FileExist(O1)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    FreeBitmaps() {
        For HBITMAP In BitMaps
            IsSet(HBITMAP) ? DllCall("DeleteObject", "Ptr", HBITMAP) : 0
        BitMaps := []
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetARGB(RGB) {
        ARGB := HTML.HasOwnProp(RGB) ? HTML.%RGB% : RGB
        Return (ARGB & 0xFF000000) = 0 ? 0xFF000000 | ARGB : ARGB
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetRGB(BGR) {
        Return ((BGR & 0xFF0000) >> 16) | (BGR & 0x00FF00) | ((BGR & 0x0000FF) << 16)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    PathAddRectangle(Path, X, Y, W, H) {
        Return DllCall("Gdiplus.dll\GdipAddPathRectangle", "Ptr", Path, "Float", X, "Float", Y, "Float", W, "Float", H)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    PathAddRoundedRect(Path, X1, Y1, X2, Y2, R) {
        D := (R * 2), X2 -= D, Y2 -= D
        DllCall("Gdiplus.dll\GdipAddPathArc",
            "Ptr", Path, "Float", X1, "Float", Y1, "Float", D, "Float", D, "Float", 180, "Float", 90)
        DllCall("Gdiplus.dll\GdipAddPathArc",
            "Ptr", Path, "Float", X2, "Float", Y1, "Float", D, "Float", D, "Float", 270, "Float", 90)
        DllCall("Gdiplus.dll\GdipAddPathArc",
            "Ptr", Path, "Float", X2, "Float", Y2, "Float", D, "Float", D, "Float", 0, "Float", 90)
        DllCall("Gdiplus.dll\GdipAddPathArc",
            "Ptr", Path, "Float", X1, "Float", Y2, "Float", D, "Float", D, "Float", 90, "Float", 90)
        Return DllCall("Gdiplus.dll\GdipClosePathFigure", "Ptr", Path)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetRect(&Rect, L := 0, T := 0, R := 0, B := 0) {
        Rect := Buffer(16, 0)
        NumPut("Int", L, "Int", T, "Int", R, "Int", B, Rect)
        Return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetRectF(&Rect, X := 0, Y := 0, W := 0, H := 0) {
        Rect := Buffer(16, 0)
        NumPut("Float", X, "Float", Y, "Float", W, "Float", H, Rect)
        Return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ErrorExit(ErrMsg) {
        If (Bitmap)
            DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", Bitmap)
        If (Graphics)
            DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", Graphics)
        If (Font)
            DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", Font)
        If (StringFormat)
            DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", StringFormat)
        If (HIML) {
            BIL := Buffer(20 + A_PtrSize, 0)
            NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
            DllCall("SendMessage", "Ptr", HWND, "UInt", 0x1602, "Ptr", 0, "Ptr", BIL) ; BCM_SETIMAGELIST
            IL_Destroy(HIML)
        }
        Bitmap := 0
        Graphics := 0
        Font := 0
        StringFormat := 0
        HIML := 0
        FreeBitmaps()
        Throw Error(ErrMsg)
    }
}
; ----------------------------------------------------------------------------------------------------------------------
; Loads and initializes the Gdiplus.dll.
; Must be called once before you use any of the DLL functions.
; ----------------------------------------------------------------------------------------------------------------------
#DllLoad "Gdiplus.dll"
UseGDIP() {
    Static GdipObject := 0
    If !IsObject(GdipObject) {
        GdipToken := 0
        SI := Buffer(24, 0) ; size of 64-bit structure
        NumPut("UInt", 1, SI)
        If DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", &GdipToken, "Ptr", SI, "Ptr", 0, "UInt") {
            MsgBox("GDI+ could not be startet!`n`nThe program will exit!", A_ThisFunc, 262160)
            ExitApp
        }
        GdipObject := { __Delete: UseGdipShutDown }
    }
    UseGdipShutDown(*) {
        DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GdipToken)
    }
}