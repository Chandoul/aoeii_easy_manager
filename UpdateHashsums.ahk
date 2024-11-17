#Requires AutoHotkey v2
#SingleInstance Force
F1:: {
    RunWait('DB\7za a -mx9 -v50m Scripts.7z '
          . ' "AoE II Manager AIO Ex.ahk"'
          . ' "Game.ahk"'
          . ' "Version.ahk"'
          . ' "Fixes.ahk"'
          . ' "Language.ahk"'
          . ' "VM.ahk"'
          . ' "DM.ahk"'
          . ' "VPN.ahk"'
          . ' "DDF.ahk"'
          . ' "SharedLib.ahk"'
          . ' "Installer.ahk"'
          . ' "Uninstaller.ahk"'
          . ' "UninstallGame.ahk"'
          . ' "Shortcuts\"'
        )
}