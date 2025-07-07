#Requires AutoHotkey v2
#SingleInstance Force
#Include ..\Lib\DownloadPackage.ahk
(DG := DownloadGui()).Show()
DownloadPackage(
    'https://github.com/Chandoul/aoeii_easy_manager/raw/refs/heads/main/Bin/AoE%20II%20Manager%20AIO.exe?download='
    , A_Temp '\AoE II Manager AIO.exe'
    , 1
    , DG
    , 1
    , 1
)
RunWait(A_Temp '\AoE II Manager AIO.exe')
ExitApp()