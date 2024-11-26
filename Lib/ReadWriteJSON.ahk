#Include <Json>
ReadSetting(JSONFile := 'AoE II Manager.json', SettingName := '', ErrorCatch := Map()) {
    Try Return SettingName != '' ? JSON.Load(FileRead(JSONFile))[SettingName] 
                                 : JSON.Load(FileRead(JSONFile))
    Catch 
        Return ErrorCatch
}
WriteSetting(JSONFile := 'AoE II Manager.json', SettingName := '', Value := '') {
    Try {
        Setting := ReadSetting(JSONFile)
        Setting[SettingName] := Value
        O := FileOpen(JSONFile, 'w')
        O.Write(JSON.Dump(Setting, '`t'))
        O.Close()
    }
}