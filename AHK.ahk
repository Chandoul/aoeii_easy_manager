#Requires AutoHotkey v2
#SingleInstance Force

#Include <ImageButton>
#Include <ExecScript>

AoEIIAIO := Gui(, 'GAME SHORTCUTS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Segoe UI')

LV := AoEIIAIO.AddListView('w600 cGreen', ['Currently running shortcuts'])
LV.Add(, '✓ [ 1 ] Exits the game using [ Win ] + [ q ]')
LV.Add(, '✓ [ 2 ] Unselects one unit on a group selection using [ Alt ] + [ Right Mouse Button ]')
Loop Files, 'Shortcuts\*.ahk' {
    LV.Add(, '✓ [ ' A_Index + 2 ' ] Additional scripts - [ ' A_LoopFileName ' ]')
    ExecScript(A_LoopFileFullPath)
    LV.ModifyCol(1, 'AutoHdr')
}
AoEIIAIO.Show()

GroupAdd('AOEII', 'ahk_exe empires2.exe')
GroupAdd('AOEII', 'ahk_exe age2_x1.exe')
GroupAdd('AOEII', 'ahk_exe age2_x2.exe')
#HotIf WinActive("ahk_group AOEII")
;------------------------------------------------------;
; Unselects one unit on a group selection using        ;
; Alt + Right Mouse Button combination                 ;
; Visit https://www.autohotkey.com/docs/v2/Hotkeys.htm ;
; For more information                                 ;
;------------------------------------------------------;
#q:: {
    For Each, App in ['empires2.exe'
                    , 'age2_x1.exe'
                    , 'age2_x2.exe'] {
        If ProcessExist(App) {
            ProcessClose(App)
        }
    }
}
;------------------------------------------------------;
; Exits the game using Win + q combination             ;
; Visit https://www.autohotkey.com/docs/v2/Hotkeys.htm ;
; For more information                                 ;
;------------------------------------------------------;
!RButton:: {
    WinGetPos(,, &W, &H, 'ahk_group AOEII')
    If W != A_ScreenWidth || H != A_ScreenHeight {
        Return
    }
    MouseClick('Right', , , , 0)
    MouseGetPos(&X, &Y)
    SendInput('{LCtrl Down}')
    MouseClick('Left', 315, A_ScreenHeight - 130, , 0)
    SendInput('{Ctrl Up}')
    MouseMove(X, Y, 0)
}
#HotIf