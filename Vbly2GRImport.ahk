#Requires AutoHotkey v2
#SingleInstance Force
#Include <ReadWriteJSON>
FileEncoding('UTF-8')
DrsBuild := 'DB\Base\DrsBuild.exe'
DrsData := 'gamedata_x1_p1.drs'
LngDLL := ['DB\Base\language_x1_p1.dll', 'language_x1_p1.dll']
mmodsDLL := ['DB\Base\aoc-language-ini.dll', 'aoc-language-ini.dll']
DMPackage := ReadSetting(, 'DMPackage')
PackID := InputBox('Pack ID', 'Pack ID', 'w200 h90', DMPackage.Count + 9)
SevenZip := 'DB\7za.exe'
Zeros := 5

((PackID.Result != 'OK') || (!Mode := FileSelect('D'))) && ExitApp()
SplitPath(Mode, &ModeName)

ToolTip 'Create mode directory'
If DirExist('tmp\' ModeName)
    DirDelete('tmp\' ModeName, 1)
DirCreate('tmp\' ModeName)

ToolTip 'Copy ' Mode '\age2_x1.xml'
If FileExist(Mode '\age2_x1.xml')
    FileCopy(Mode '\age2_x1.xml', 'tmp\' ModeName '\age2_x1.xml')

ToolTip 'Update the mod xml path'
XML := FileRead('tmp\' ModeName '\age2_x1.xml')
XML := RegExReplace(XML, '<path>.*</path>', '<path>' ModeName '</path>')
FileOpen('tmp\' ModeName '\age2_x1.xml', 'w').Write(XML)

ToolTip 'Copy ' Mode '\Data'
If DirExist(Mode '\Data')
    DirCopy(Mode '\Data', 'tmp\' ModeName '\Data')

If FileExist('tmp\' ModeName '\Data\' DrsData) {
    If !DirExist('tmp\' ModeName '\Drs')
        DirCreate('tmp\' ModeName '\Drs')
    ToolTip 'Extract drs file ' ModeName '\Data\' DrsData
    RunWait(A_ComSpec ' /c ' DrsBuild ' /e "tmp\' ModeName '\Data\' DrsData '" /o "tmp\' ModeName '\Drs"')
    FileDelete('tmp\' ModeName '\Data\' DrsData)
}
ToolTip 'Copy ' Mode '\Drs'
If DirExist(Mode '\Drs') {
    
    DirCopy(Mode '\Drs', 'tmp\' ModeName '\Drs', 1)
    ToolTip 'Adding game prefix'
    Loop Files, 'tmp\' ModeName '\Drs\*.*' {
        FileN := A_LoopFileFullPath
        VooblyCodedSlpCheck(A_LoopFileFullPath)
        SplitPath(FileN, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt)
        If !InStr(OutFileName, 'gam') {
            FileMove(FileN, OutDir '\gam' Format('{:0' Zeros '}', OutNameNoExt) '.' OutExtension, 1)
        }
        ToolTip(A_Index ' treated')
    }
    ToolTip 'Build ' ModeName '\Data\' DrsData
    RunWait(A_ComSpec ' /c ' DrsBuild ' /a "tmp\' ModeName '\Data\' DrsData '" "' OutDir '\*.slp"')
    RunWait(A_ComSpec ' /c ' DrsBuild ' /a "tmp\' ModeName '\Data\' DrsData '" "' OutDir '\*.wav"')
    RunWait(A_ComSpec ' /c ' DrsBuild ' /a "tmp\' ModeName '\Data\' DrsData '" "' OutDir '\*.bina"')
    RunWait(A_ComSpec ' /c ' DrsBuild ' /a "tmp\' ModeName '\Data\' DrsData '" "' OutDir '\*.bin"')
    
    ToolTip 'Delete ' ModeName '\Drs'
    DirDelete('tmp\' ModeName '\Drs', 1)
}

ToolTip 'Copy ' LngDLL[1]
If FileExist(LngDLL[1])
    FileCopy(LngDLL[1], 'tmp\' ModeName '\Data\' LngDLL[2])

ToolTip 'Create ' ModeName '\mmods'
DirCreate('tmp\' ModeName '\mmods')

ToolTip 'Copy ' mmodsDLL[1]
If FileExist(mmodsDLL[1])
    FileCopy(mmodsDLL[1], 'tmp\' ModeName '\mmods\' mmodsDLL[2])

ToolTip 'Copy ' Mode '\SaveGame'
If DirExist(Mode '\SaveGame')
    DirCopy(Mode '\SaveGame', 'tmp\' ModeName '\SaveGame')

ToolTip 'Copy ' Mode '\Scenario'
If DirExist(Mode '\Scenario')
    DirCopy(Mode '\Scenario', 'tmp\' ModeName '\Scenario')

ToolTip 'Copy ' Mode '\Screenshots'
If DirExist(Mode '\Screenshots')
    DirCopy(Mode '\Screenshots', 'tmp\' ModeName '\Screenshots')

ToolTip 'Copy ' Mode '\Script.AI'
If DirExist(Mode '\Script.AI')
    DirCopy(Mode '\Script.AI', 'tmp\' ModeName '\Script.AI')

ToolTip 'Copy ' Mode '\Sound'
If DirExist(Mode '\Sound')
    DirCopy(Mode '\Sound', 'tmp\' ModeName '\Sound')

ToolTip 'Copy ' Mode '\Taunt'
If DirExist(Mode '\Taunt')
    DirCopy(Mode '\Taunt', 'tmp\' ModeName '\Taunt')

ToolTip 'Copy ' Mode '\language.ini'
If FileExist(Mode '\language.ini')
    FileCopy(Mode '\language.ini', 'tmp\' ModeName '\language.ini')

ToolTip 'Copy ' Mode '\version.ini'
If FileExist(Mode '\version.ini')
    FileCopy(Mode '\version.ini', 'tmp\' ModeName '\version.ini')

ToolTip 'Finish up'
DirCreate('tmp\tmpMode\Games\')
FileMove('tmp\' ModeName '\age2_x1.xml', 'tmp\tmpMode\Games\age2_x1.xml')
DirMove('tmp\' ModeName, 'tmp\tmpMode\Games\' ModeName)
DirMove('tmp\tmpMode', 'tmp\' ModeName)

ToolTip 'Packing it up'
PackName := Format('{:03}', PackID.Value)
Try FileDelete(PackName '*')

RunWait(A_ComSpec ' /k ' SevenZip ' a -mx9 -v50m DB\' PackName '.7z ".\tmp\' ModeName '\Games"')

MsgBox(ModeName ' import complete!', 'Done', 0x40)

VooblyCodedSlpCheck(File) {
    Static Header := '0xbe 0xef 0x13 0x37'
    Buff := FileRead(File, 'RAW m4')
    For Val in StrSplit(Header, ' ') {
        Hex := Format('{:#x}', NumGet(Buff, A_Index - 1, 'UChar'))
        If Val = Hex {
            Msgbox File
        }
    }
}