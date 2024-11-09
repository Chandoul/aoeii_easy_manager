#Requires AutoHotkey v2
DetectHiddenWindows(True)
#SingleInstance Force
; Checks if the script run as admin
If !A_IsAdmin {
    MsgBox('Script must run as administrator!', 'Warn', 0x30)
    ExitApp
}
; Inits
Version := '2.4'
Features := Map()
Config := 'Config.ini'
GRSetting := A_AppData '\GameRanger\GameRanger Prefs\Settings'
GRApp := A_AppData '\GameRanger\GameRanger\GameRanger.exe'
DownloadDB := 'https://raw.githubusercontent.com/SmileAoE/aoeii_aio/main'
LinkHashs := DownloadDB '/Hashsums.ini'
BasePackages := ['DB/000.7z.001', 'DB/001.7z.001', 'DB/002.7z.001', 'DB/006.7z.001', 'DB/007.7z.001', 'DB/007.7z.002', 'Shortcuts.7z.001', 'Scripts.7z.001']
GamePackages := ['DB/003.7z.001', 'DB/003.7z.002', 'DB/003.7z.003', 'DB/003.7z.004', 'DB/004.7z.001', 'DB/004.7z.002', 'DB/004.7z.003', 'DB/005.7z.001']
RestPackages := ['DB/009.7z.001', 'DB/009.7z.002', 'DB/010.7z.001', 'DB/010.7z.002', 'DB/010.7z.003', 'DB/010.7z.004', 'DB/010.7z.005', 'DB/011.7z.001', 'DB/012.7z.001', 'DB/013.7z.001', 'DB/014.7z.001', 'DB/014.7z.002']
AllPackagesC := [BasePackages, GamePackages, RestPackages]
IBRed := [[0xFFFFFF,, 0xFF0000, 4, 0xFF0000, 2], [0xFF0000,, 0xFFFFFF], [0xFF0000,, 0xFFFF00], [0xFFFFFF,, 0xCCCCCC,, 0xCCCCCC]]
IBBlue := [[0xFFFFFF,, 0x0000FF, 4, 0x0000FF, 2], [0x0000FF,, 0xFFFFFF], [0x0000FF,, 0xFFFF00], [0xFFFFFF,, 0xCCCCCC,, 0xCCCCCC]]
IBBlack := [[0xFFFFFF,, 0x000000, 4, 0x000000, 2], [0x000000,, 0xFFFFFF], [0x000000,, 0xFFFF00], [0xFFFFFF,, 0xCCCCCC,, 0xCCCCCC]]
IBGray := [[0xFFFFFF,, 0x000000, 4, 0xCCCCCC, 2], [0xAAAAAA], [0xBBBBBB], [0xFFFFFF,, 0xCCCCCC]]
Unpacker := 'DB\7za.exe'
DrsMap := Map('gra', 'graphics.drs', 'int', 'interfac.drs', 'ter', 'terrain.drs')
Layers := 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
SetRegView(32)
; Builds up graphics
AoEIIAIO := Gui(, 'Age of Empires II Easy Manager!')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', ExitScript)
; ExitScript(HGUI)
ExitScript(HGui) {
    ExitApp()
}
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Calibri')
; Prepare packages
Prepare := Gui(, 'Preparing...')
Prepare.OnEvent('Close', ExitScript)
Prepare.AddText('Center w400 h25', 'Please Wait...').SetFont('s12 Bold')
ProgressBar := Prepare.AddProgress('Center w400 h20 -Smooth Range1-' BasePackages.Length + 1)
ProgressText := Prepare.AddText('Center wp cBlue')
Prepare.Show()
; Base packages
Try {
    If !DirExist('DB') {
        DirCreate('DB')
    }
    If !FileExist('DB\7za.exe') {
        Download(DownloadDB '/DB/7za.exe', 'DB\7za.exe')
    }
    For Package in BasePackages {
        ProgressBar.Value += 1
        ProgressText.Text := 'Preparing [ ' Package ' ]'
        PackagePath := StrReplace(Package, '/', '\')
        SplitPath(PackagePath, &OutFileName, &OutDir)
        PackageFolder := (OutDir ? OutDir '\' : '') StrSplit(OutFileName, '.')[1]
        If !FileExist(PackagePath) {
            DownloadPackage(Package, PackagePath, PackageFolder)
        }
        PackHead := StrGet(FileRead(PackagePath, 'RAW m2'), 2, 'CP0')
        If (PackHead = '7z') && !DirExist(PackageFolder) {
            ExtractPackage(PackagePath, PackageFolder, True)
        }
    }
} Catch Error As Err {
    MsgBox("Launch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
}
Prepare.Hide()
; Closes the game if it is open
CloseGame() {
    For Each, App in ['empires2.exe', 'age2_x1.exe', 'age2_x2.exe'] {
        If ProcessExist(App) {
            Try {
                ProcessClose(App)
                ProcessWaitClose(App, 5)
            } Catch Error As Err {
                MsgBox("Game close failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
            }
        }
    }
}
; Defaults the push button version
DefaultPB(Versions) {
    For Each, Version in Versions {
        CreateImageButton(Version, 0, [[0xFFFFFF,, 0x0000FF, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        Version.Redraw()
    }
}
; Controls enable or disable
EnableControls(Controls, Enable := 1) {
    If Enable {
        For Each, Control in Controls {
            Control.Enabled := True
        }
    } Else {
        For Each, Control in Controls {
            Control.Enabled := False
        }
    }
}
; Checks if a directory contains the game
ValidGameDirectory(Location) {
    Return   FileExist(Location '\empires2.exe')
          && FileExist(Location '\language.dll')
          && FileExist(Location '\Data\graphics.drs')
          && FileExist(Location '\Data\interfac.drs')
          && FileExist(Location '\Data\terrain.drs') ? 1 : 0
}
; Returns the updated packages hashs
UpdatedPackagesHashs() {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", LinkHashs, true)
    whr.Send()
    whr.WaitForResponse()
    Data := Trim(whr.ResponseText, '`n`r')
    Hashs := Map()
    Loop Parse, Data, '`n`r' {
        Pair := StrSplit(A_LoopField, '=')
        Hashs[Pair[1]] := Pair[2]
    }
    Return Hashs
}
; Downloads a given package
DownloadPackage(Package, PackagePath, PackageFolder) {
    If !FileExist(PackagePath) {
        Download(DownloadDB '/' Package, PackagePath)
        If PackageFolder != '' && DirExist(PackageFolder) {
            DirDelete(PackageFolder, 1)
        }
    }
}
; Extracts a given package
ExtractPackage(PackagePath, PackageFolder, Overwrite := 0) {
    If PackageFolder = 'Scripts' {
        PackageFolder := A_ScriptDir
    }
    Overwrite := Overwrite ? Overwrite : !DirExist(PackageFolder)
    If Overwrite && FileExist(PackagePath) {
        RunWait(Unpacker ' x ' PackagePath ' -o"' PackageFolder '" -aoa',, 'Hide')
    }
}
; Check if there is internet connection
ConnectedToInternet(Flag := 0x40) {
    Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag, "Int", 0)
}
; Class ScrollBar
Class ScrollBar {
    ; Notification codes for horizontal and vertical scroll
    WM_HSCROLL => 0x114
    WM_VSCROLL => 0x115

    ; type of scroll bar (nBar)
    SB_HORZ => 0
    SB_VERT => 1
    SB_BOTH => 3

    ; Scroll bar parameters to set or retrieve (fMask)
    SIF_RANGE => 1
    SIF_PAGE => 2
    SIF_POS => 4
    SIF_TRACKPOS => 16
    SIF_ALL => this.SIF_RANGE | this.SIF_PAGE | this.SIF_POS | this.SIF_TRACKPOS

    ; Scroll Bar Commands
    ; The user pressed the LEFT ARROW (VK_LEFT) key or clicked the left arrow button on a horizontal scroll bar.
    SB_LINELEFT => 0
    ; The user pressed the UP ARROW (VK_UP) key or clicked the up arrow button on a vertical scroll bar.
    SB_LINEUP => 0
    ; The user pressed the RIGHT ARROW (VK_RIGHT) key or clicked the right arrow button on a horizontal scroll bar.
    SB_LINERIGHT => 1
    ; The user pressed the DOWN ARROW (VK_DOWN) key or clicked the down arrow button on a vertical scroll bar.
    SB_LINEDOWN => 1
    ; The user clicked the channel above the slider on a vertical scroll bar or to the left of the slider on a horizontal scroll bar (VK_PRIOR).
    SB_PAGELEFT => 2
    SB_PAGEUP => 2
    ; The user clicked the channel below the slider on a vertical scroll bar or to the right of the slider on a horizontal scroll bar (VK_NEXT).
    SB_PAGERIGHT => 3
    SB_PAGEDOWN => 3
    ; The scrollbar received WM_LBUTTONUP following a SB_THUMBTRACK notification code.
    SB_THUMBPOSITION => 4
    ; The user dragged the slider.
    SB_THUMBTRACK => 5
    ; The user pressed the HOME key (VK_HOME) or clicked the top arrow button on a vertical scroll bar or left arrow button on a horizontal scroll bar.
    SB_LEFT => 6
    SB_TOP => 6
    ; The user pressed the END key (VK_END) or clicked the bottom arrow button on a vertical scroll bar or right arrow button on a horizontal scroll bar.
    SB_RIGHT => 7
    SB_BOTTOM => 7
    ; The scrollbar received WM_KEYUP, meaning that the user released a key that sent a relevant virtual key code.
    SB_ENDSCROLL => 8
    ; Custom
    GAMELOCATION => 100
    OPTION => 101
    GAMEVERSION => 102
    GAMELANGUAGES => 103
    GAMEVISUALMODS => 104
    GAMEDATAMODS => 105
    GAMEOTHERTOOLS => 106

    ; Constructor for the ScrollBar class
    __New(guiObj, width, height) {
        ; Check if the first parameter is a Gui object
        if (guiObj is Gui) {
            ; Set the guiObj property to the first parameter
            this.guiObj := guiObj
            ; Show both scroll bars
            this.ShowScrollBar(this.SB_BOTH, true)

            ; Create a buffer for the rectangle
            this.Rect := Buffer(16)

            this.FixedControls := []

            ; Bind the ScrollMsg method to this object and set it as the message handler for WM_HSCROLL and WM_VSCROLL messages
            this.ScrollMsgBind := ObjBindMethod(this, 'ScrollMsg')
            OnMessage(this.WM_HSCROLL, this.ScrollMsgBind)
            OnMessage(this.WM_VSCROLL, this.ScrollMsgBind)

            ; Do update of scroll bars when I resize the window
            this.guiObj.OnEvent('Size', (*) => this.UpdateScrollBars())

            ; Create a new SCROLLINFO object
            this.ScrollInf := SCROLLINFO()

            ; Gets left-most, right-most, top-most, bottom-most control positions
            this.GetEdges(&Left, &Right, &Top, &Bottom)

            ; Calculate the scroll height and width
            ScrollHeight := Bottom - Top
            ScrollWidth := Right - Left

            if (IsNumber(width) and IsNumber(height) and width > 0 and height > 0) {
                ; Set the maximum scroll position and page size for the vertical scroll bar
                this.ScrollInf.nMax := ScrollHeight
                this.ScrollInf.nPage := height

                this.ScrollInf.fMask := this.SIF_RANGE | this.SIF_PAGE

                ; Set the scroll info for the vertical scroll bar
                this.SetScrollInfo(this.SB_VERT, true)

                ; Set the maximum scroll position and page size for the horizontal scroll bar
                this.ScrollInf.nMax := ScrollWidth
                this.ScrollInf.nPage := width

                ; Set the scroll info for the horizontal scroll bar
                this.SetScrollInfo(this.SB_HORZ, true)

                ; Set the mask to retrieve all scroll info
                this.ScrollInf.fMask := this.SIF_ALL
            } else throw Error('Width and height must be valid numbers') ; Throw an error if width or height are not valid numbers
        } else throw Error('Parameter is not a Gui object') ; Throw an error if the first parameter is not a Gui object
    }

    ; Updates the position of fixed controls while the user scrolls
    UpdateFixedControlsPosition() {
        ; Iterates over the list of fixed controls
        for control in this.FixedControls {
            ; Sets the new position of the control
            control.Move(control.startX, control.startY)
        }
    }

    ; Add fixed controls...
    AddFixedControls(controls) {
        ; Verifies if the parameter is an array
        if (!(controls is Array)) {
            throw Error('Parameter must be an array of controls')
        }

        ; Adds each control to the list of fixed controls
        for control in controls {
            ; Gets the coordinates of the control
            control.GetPos(&controlX, &controlY)
            control.startX := controlX
            control.startY := controlY
            ; Stores the control in the list of fixed controls
            this.FixedControls.Push(control)
        }
    }

    UpdateScrollBars() {
        ; Gets left-most, right-most, top-most, bottom-most control positions
        this.GetEdges(&Left, &Right, &Top, &Bottom)

        ; Calculate the scroll width and height
        ScrollWidth := Right - Left
        ScrollHeight := Bottom - Top

        ; Set the mask to update the range and page size of the scroll bar
        this.ScrollInf.fMask := this.SIF_RANGE | this.SIF_PAGE

        ; Update the maximum scroll position and page size for the vertical scroll bar
        this.ScrollInf.nMax := ScrollHeight
        this.ScrollInf.nPage := this.GetHeight()

        ; Set the scroll info for the vertical scroll bar
        this.SetScrollInfo(this.SB_VERT, true)

        ; Update the maximum scroll position and page size for the horizontal scroll bar
        this.ScrollInf.nMax := ScrollWidth
        this.ScrollInf.nPage := this.GetWidth()

        ; Set the scroll info for the horizontal scroll bar
        this.SetScrollInfo(this.SB_HORZ, true)

        /*
        The code below checks if the left or top position of the content is less than 0 and if
        the right or bottom position of the content is less than the width or height of the window. If
        both conditions are true for either axis, it calculates how much to scroll in that axis to bring
        the content back into view. It then calls the ScrollWindow function to scroll the content by that
        amount in both axes.
        */

        x := 0, y := 0

        if (Left < 0 && Right < this.GetWidth()) {
            x := Abs(Left) > this.GetWidth() - Right ? this.GetWidth() - Right : Abs(Left)
        }
        if (Top < 0 && Bottom < this.GetHeight()) {
            y := Abs(Top) > this.GetHeight() - Bottom ? this.GetHeight() - Bottom : Abs(Top)
        }
        if (x || y) {
            DllCall("ScrollWindow", "ptr", this.guiObj.Hwnd, "int", x, "int", y, "uint", 0, "uint", 0)
        }

        ; Set the mask to retrieve all scroll info
        this.ScrollInf.fMask := this.SIF_ALL
    }

    HiWord(wParam) {
        Return (wParam >> 16)
    }

    LoWord(wParam) {
        Return (wParam & 0xFFFF)
    }

    ; The ScrollMsg function is called when the window receives a WM_HSCROLL or WM_VSCROLL message.
    ; It calls the ScrollAction function to update the scroll bar position and then calls the ScrollWindow function to scroll the content.
    ScrollMsg(wParam, lParam, msg, hwnd) {
        switch msg {
            ; If the message is WM_HSCROLL, update the horizontal scroll bar
            case this.WM_HSCROLL:
                this.ScrollAction(this.SB_HORZ, wParam)
                this.ScrollWindow(this.oldPos - this.ScrollInf.nPos, 0)
                this.UpdateFixedControlsPosition()
            ; If the message is WM_VSCROLL, update the vertical scroll bar
            case this.WM_VSCROLL:
                this.ScrollAction(this.SB_VERT, wParam)
                this.ScrollWindow(0, this.oldPos - this.ScrollInf.nPos)
                this.UpdateFixedControlsPosition()
        }
    }

    ; The ScrollAction function updates the scroll bar position based on the scroll action specified in wParam.
    ; It first gets the current scroll info and position for the specified scroll bar and then calculates the new position based on the scroll action.
    ScrollAction(typeOfScrollBar, wParam) {
        ; Get current attributes of scroll bar
        this.GetScrollInfo(typeOfScrollBar)

        ; Store current position of scroll bar
        this.oldPos := this.ScrollInf.nPos

        ; Get current scroll range
        this.GetScrollRange(typeOfScrollBar, &minPos, &maxPos)

        ; Calculates max position of scroll bar's thumb (scroll box)
        maxThumbPos := this.ScrollInf.nMax - this.ScrollInf.nMin + 1 - this.ScrollInf.nPage

        ; Updates scroll bar position based on command received
        switch this.LoWord(wParam) {
            case this.SB_LINELEFT, this.SB_LINEUP:
                this.ScrollInf.nPos := max(this.ScrollInf.nPos - 40, minPos)
            case this.SB_PAGELEFT, this.SB_PAGEUP:
                this.ScrollInf.nPos := max(this.ScrollInf.nPos - this.ScrollInf.nPage, minPos)
            case this.SB_LINERIGHT, this.SB_LINEDOWN:
                this.ScrollInf.nPos := min(this.ScrollInf.nPos + 40, maxThumbPos)
            case this.SB_PAGERIGHT, this.SB_PAGEDOWN:
                this.ScrollInf.nPos := min(this.ScrollInf.nPos + this.ScrollInf.nPage, maxThumbPos)
            case this.SB_THUMBTRACK:
                this.ScrollInf.nPos := this.HiWord(wParam)
            case this.SB_LEFT, this.SB_TOP:
                this.ScrollInf.nPos := minPos
            case this.SB_RIGHT, this.SB_BOTTOM:
                this.ScrollInf.nPos := maxThumbPos
            case this.GAMELOCATION:
                this.ScrollInf.nPos := 285
            case this.OPTION:
                this.ScrollInf.nPos := 530
            case this.GAMEVERSION:
                this.ScrollInf.nPos := 700
            case this.GAMELANGUAGES:
                this.ScrollInf.nPos := 1170
            case this.GAMEVISUALMODS:
                this.ScrollInf.nPos := 1649
            case this.GAMEDATAMODS:
                this.ScrollInf.nPos := 5941
            default:
                return
        }
        this.ScrollInf.nPos := this.ScrollInf.nPos < 0 ? 0 : this.ScrollInf.nPos
        this.SetScrollInfo(typeOfScrollBar, true)
    }

    GetClientRect() {
        return DllCall("GetClientRect", "uint", this.guiObj.Hwnd, "ptr", this.Rect.Ptr)
    }

    ; Gets current visible height
    GetHeight() {
        this.GetClientRect()
        return NumGet(this.Rect, 12, "int")
    }

    ; Gets current visible height
    GetWidth() {
        this.GetClientRect()
        return NumGet(this.Rect, 8, "int")
    }

    ; Gets left-most, right-most, top-most, bottom-most control positions
    GetEdges(&Left?, &Right?, &Top?, &Bottom?) {
        ; Calculate scrolling area.
        Left := Top := 9999
        Right := Bottom := 0
        ; Get a list of all controls in guiObj
        ControlList := WinGetControls(this.guiObj.Hwnd)
        ; Loops through all controls and finds the farthest sides
        For i in ControlList {
            ; Gets all positions of current control
            this.guiObj[i].GetPos(&cX, &cY, &cW, &cH)
            ; If it's position is farther than the last one, saves it
            if (cX < Left) {
                Left := cX
            }
            if (cY < Top) {
                Top := cY
            }
            if (cX + cW > Right) {
                Right := cX + cW
            }
            if (cY + cH > Bottom) {
                Bottom := cY + cH
            }
        }

        ; Gives a little more space for the edges
        Left -= 8
        Top -= 8
        Right += 8
        Bottom += 8
    }

    ; The ShowScrollBar function shows or hides the specified scroll bar.
    ; f the function succeeds, the return value is nonzero.
    ShowScrollBar(typeOfScrollBar, bool) {
        return DllCall("ShowScrollBar", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "int", bool)
    }

    ; The GetScrollInfo function retrieves the parameters of a scroll bar, including the minimum and maximum scrolling positions,
    ; the page size, and the position of the scroll box (thumb).
    ; Before calling GetScrollInfo, set the cbSize member to sizeof(SCROLLINFO), and set the fMask member to specify the scroll bar parameters to retrieve.
    ; If the function retrieved any values, the return value is nonzero.
    GetScrollInfo(typeOfScrollBar) {
        return DllCall("GetScrollInfo", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", this.ScrollInf.Ptr)
    }

    ; The SetScrollInfo function sets the parameters of a scroll bar, including the minimum and maximum scrolling positions,
    ; the page size, and the position of the scroll box (thumb). The function also redraws the scroll bar, if requested.
    ; The return value is the current position of the scroll box.
    SetScrollInfo(typeOfScrollBar, redraw) {
        return DllCall("SetScrollInfo", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", this.ScrollInf.Ptr, "int", redraw)
    }

    ; The GetScrollRange function retrieves the current minimum and maximum scroll box (thumb) positions for the specified scroll bar.
    ; If the function succeeds, the return value is nonzero.
    GetScrollRange(typeOfScrollBar, &minPos, &maxPos) {
        minnn := Buffer(4)
        maxxx := Buffer(4)
        r := DllCall("GetScrollRange", "ptr", this.guiObj.Hwnd, "int", typeOfScrollBar, "ptr", minnn.Ptr, "ptr", maxxx.Ptr)
        minPos := NumGet(minnn, "int"), maxPos := NumGet(maxxx, "int")
        return r
    }

    ; The ScrollWindow function scrolls the contents of the specified window's client area.
    ; If the function succeeds, the return value is nonzero.
    ScrollWindow(xamount, yamount) {
        return DllCall("ScrollWindow", "ptr", this.guiObj.Hwnd, "int", xamount, "int", yamount, "ptr", 0, "ptr", 0, "int")
    }
}
Class ScrollInfo {
    ;/* This class defines the structure below(SCROLLINFO) on Winuser.h:
    ;
    ;typedef struct tagSCROLLINFO {
    ;  UINT cbSize;
    ;  UINT fMask;
    ;  int  nMin;
    ;  int  nMax;
    ;  UINT nPage;
    ;  int  nPos;
    ;  int  nTrackPos;
    ;} SCROLLINFO, *LPSCROLLINFO */
    __New() {
        ; Reserves space in computer memory for scrollInf structure with 28 bytes
        this.scrollInf := Buffer(28, 0)
        ; Set cbSize
        NumPut("uint", this.scrollInf.size, this.scrollInf)
    }

    Ptr => this.scrollInf.Ptr

    ; cbSize: Specifies the size, in bytes, of this structure. The caller must set this to sizeof(SCROLLINFO).
    cbSize => NumGet(this.scrollInf, "uint")

    /*  Specifies the scroll bar parameters to set or retrieve. This member can be a combination of the following values:

    SIF_ALL                     Combination of SIF_PAGE, SIF_POS, SIF_RANGE, and SIF_TRACKPOS.
    SIF_DISABLENOSCROLL         If the scroll bar's new parameters make the scroll bar unnecessary, disable the scroll bar instead of removing it.
    SIF_PAGE                    The nPage member contains the page size for a proportional scroll bar.
    SIF_POS                     The nPos member contains the scroll box position, which is not updated while the user drags the scroll box.
    SIF_RANGE                   The nMin and nMax members contain the minimum and maximum values for the scrolling range.
    SIF_TRACKPOS                The nTrackPos member contains the current position of the scroll box while the user is dragging it.                 */
    fMask {
        get => NumGet(this.scrollInf, 4, "uint")
        set => NumPut("uint", value, this.scrollInf, 4)
    }

    ; Specifies the minimum scrolling position.
    nMin {
        get => NumGet(this.scrollInf, 8, "int")
        set => NumPut("int", value, this.scrollInf, 8)
    }

    ; Specifies the maximum scrolling position.
    nMax {
        get => NumGet(this.scrollInf, 12, "int")
        set => NumPut("int", value, this.scrollInf, 12)
    }

    ; Specifies the page size, in device units. A scroll bar uses this value to determine the appropriate size of the proportional scroll box.
    nPage {
        get => NumGet(this.scrollInf, 16, "uint")
        set => NumPut("uint", value, this.scrollInf, 16)
    }

    ; Specifies the position of the scroll box.
    nPos {
        get => NumGet(this.scrollInf, 20, "int")
        set => NumPut("ptr", value, this.scrollInf, 20)
    }

    ; Specifies the immediate position of a scroll box that the user is dragging. An application can retrieve this value while processing the SB_THUMBTRACK request code. 
    ; An application cannot set the immediate scroll position; the SetScrollInfo function ignores this member.
    nTrackPos {
        get => NumGet(this.scrollInf, 24, "int")
        set => NumPut("ptr", value, this.scrollInf, 24)
    }
}
; Sets a push button icon 
GuiButtonIcon(Handle, File, Index := 1, Options := '') {
    RegExMatch(Options, 'i)w\K\d+', &W) ? W := W.0 : W := 16
    RegExMatch(Options, 'i)h\K\d+', &H) ? H := H.0 : H := 16
    RegExMatch(Options, 'i)s\K\d+', &S) ? W := H := S.0 : ''
    RegExMatch(Options, 'i)l\K\d+', &L) ? L := L.0 : L := 0
    RegExMatch(Options, 'i)t\K\d+', &T) ? T := T.0 : T := 0
    RegExMatch(Options, 'i)r\K\d+', &R) ? R := R.0 : R := 0
    RegExMatch(Options, 'i)b\K\d+', &B) ? B := B.0 : B := 0
    RegExMatch(Options, 'i)a\K\d+', &A) ? A := A.0 : A := 4
    W *= A_ScreenDPI / 96, H *= A_ScreenDPI / 96
    button_il := Buffer(20 + A_PtrSize)
    normal_il := DllCall('ImageList_Create', 'Int', W, 'Int', H, 'UInt', 0x21, 'Int', 1, 'Int', 1)
    NumPut('Ptr', normal_il, button_il, 0)			; Width & Height
    NumPut('UInt', L, button_il, 0 + A_PtrSize)		; Left Margin
    NumPut('UInt', T, button_il, 4 + A_PtrSize)		; Top Margin
    NumPut('UInt', R, button_il, 8 + A_PtrSize)		; Right Margin
    NumPut('UInt', B, button_il, 12 + A_PtrSize)	; Bottom Margin
    NumPut('UInt', A, button_il, 16 + A_PtrSize)	; Alignment
    SendMessage(BCM_SETIMAGELIST := 5634, 0, button_il, Handle)
    Return IL_Add(normal_il, File, Index)
}
; Checks the internet connection
GetConnectedState() {
    Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag := 0x40, "Int", 0)
}
; ======================================================================================================================
; Namespace:      LV_Colors
; Function:       Individual row and cell coloring for AHK ListView controls.
; Tested with:    AHK 2.0.2 (U32/U64)
; Tested on:      Win 10 (x64)
; Changelog:      2023-01-04/2.0.0/just me   Initial release of the AHK v2 version
; ======================================================================================================================
; CLASS LV_Colors
;
; The class provides methods to set individual colors for rows and/or cells, to clear all colors, to prevent/allow
; sorting and rezising of columns dynamically, and to deactivate/activate the notification handler for NM_CUSTOMDRAW
; notifications (see below).
;
; A message handler for NM_CUSTOMDRAW notifications will be activated for the specified ListView whenever a new
; instance is created. If you want to temporarily disable coloring call MyInstance.ShowColors(False). This must
; be done also before you try to destroy the instance. To enable it again, call MyInstance.ShowColors().
;
; To avoid the loss of Gui events and messages the message handler is set 'critical'. To prevent 'freezing' of the
; list-view or the whole GUI this script requires AHK v2.0.1+.
; ======================================================================================================================
Class LV_Colors {
    ; ===================================================================================================================
    ; __New()         Constructor - Create a new LV_Colors instance for the given ListView
    ; Parameters:     HWND        -  ListView's HWND.
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 StaticMode  -  Static color assignment, i.e. the colors will be assigned permanently to the row
    ;                                contents rather than to the row number.
    ;                                Values:  True/False
    ;                                Default: False
    ;                 NoSort      -  Prevent sorting by click on a header item.
    ;                                Values:  True/False
    ;                                Default: False
    ;                 NoSizing    -  Prevent resizing of columns.
    ;                                Values:  True/False
    ;                                Default: False
    ; ===================================================================================================================
    __New(LV, StaticMode := False, NoSort := False, NoSizing := False) {
        If (LV.Type != "ListView")
            Throw TypeError("LV_Colors requires a ListView control!", -1, LV.Type)
        ; ----------------------------------------------------------------------------------------------------------------
        ; Set LVS_EX_DOUBLEBUFFER (0x010000) style to avoid drawing issues.
        LV.Opt("+LV0x010000")
        ; Get the default colors
        BkClr := SendMessage(0x1025, 0, 0, LV) ; LVM_GETTEXTBKCOLOR
        TxClr := SendMessage(0x1023, 0, 0, LV) ; LVM_GETTEXTCOLOR
        ; Get the header control
        Header := SendMessage(0x101F, 0, 0, LV) ; LVM_GETHEADER
        ; Set other properties
        This.LV := LV
        This.HWND := LV.HWND
        This.Header := Header
        This.BkClr := BkCLr
        This.TxClr := Txclr
        This.IsStatic := !!StaticMode
        This.AltCols := False
        This.AltRows := False
        This.SelColors := False
        This.NoSort(!!NoSort)
        This.NoSizing(!!NoSizing)
        This.ShowColors()
        This.RowCount := LV.GetCount()
        This.ColCount := LV.GetCount("Col")
        This.Rows := Map()
        This.Rows.Capacity := This.RowCount
        This.Cells := Map()
        This.Cells.Capacity := This.RowCount
    }
    ; ===================================================================================================================
    ; __Delete()      Destructor
    ; ===================================================================================================================
    __Delete() {
        This.ShowColors(False)
        If WinExist(This.HWND)
            WinRedraw(This.HWND)
    }
    ; ===================================================================================================================
    ; Clear()         Clears all row and cell colors.
    ; Parameters:     AltRows     -  Reset alternate row coloring (True / False)
    ;                                Default: False
    ;                 AltCols     -  Reset alternate column coloring (True / False)
    ;                                Default: False
    ; Return Value:   Always True.
    ; ===================================================================================================================
    Clear(AltRows := False, AltCols := False) {
        If (AltCols)
            This.AltCols := False
        If (AltRows)
            This.AltRows := False
        This.Rows.Clear()
        This.Rows.Capacity := This.RowCount
        This.Cells.Clear()
        This.Cells.Capacity := This.RowCount
        Return True
    }
    ; ===================================================================================================================
    ; UpdateProps()   Updates the RowCount, ColCount, BkClr, and TxClr properties.
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    UpdateProps() {
        If !(This.HWND)
            Return False
        This.BkClr := SendMessage(0x1025, 0, 0, This.LV) ; LVM_GETTEXTBKCOLOR
        This.TxClr := SendMessage(0x1023, 0, 0, This.LV) ; LVM_GETTEXTCOLOR
        This.RowCount := This.LV.GetCount()
        This.Colcount := This.LV.GetCount("Col")
        If WinExist(This.HWND)
            WinRedraw(This.HWND)
        Return True
    }
    ; ===================================================================================================================
    ; AlternateRows() Sets background and/or text color for even row numbers.
    ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    AlternateRows(BkColor := "", TxColor := "") {
        If !(This.HWND)
            Return False
        This.AltRows := False
        If (BkColor = "") && (TxColor = "")
            Return True
        BkBGR := This.BGR(BkColor)
        TxBGR := This.BGR(TxColor)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        This.ARB := (BkBGR != "") ? BkBGR : This.BkClr
        This.ART := (TxBGR != "") ? TxBGR : This.TxClr
        This.AltRows := True
        Return True
    }
    ; ===================================================================================================================
    ; AlternateCols() Sets background and/or text color for even column numbers.
    ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    AlternateCols(BkColor := "", TxColor := "") {
        If !(This.HWND)
            Return False
        This.AltCols := False
        If (BkColor = "") && (TxColor = "")
            Return True
        BkBGR := This.BGR(BkColor)
        TxBGR := This.BGR(TxColor)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        This.ACB := (BkBGR != "") ? BkBGR : This.BkClr
        This.ACT := (TxBGR != "") ? TxBGR : This.TxClr
        This.AltCols := True
        Return True
    }
    ; ===================================================================================================================
    ; SelectionColors() Sets background and/or text color for selected rows.
    ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default selected background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default selected text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    SelectionColors(BkColor := "", TxColor := "") {
        If !(This.HWND)
            Return False
        This.SelColors := False
        If (BkColor = "") && (TxColor = "")
            Return True
        BkBGR := This.BGR(BkColor)
        TxBGR := This.BGR(TxColor)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        This.SELB := BkBGR
        This.SELT := TxBGR
        This.SelColors := True
        Return True
    }
    ; ===================================================================================================================
    ; Row()           Sets background and/or text color for the specified row.
    ; Parameters:     Row         -  Row number
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> default text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    Row(Row, BkColor := "", TxColor := "") {
        If !(This.HWND)
            Return False
        ;If (Row > This.RowCount)
        ;    Return False
        If This.IsStatic
            Row := This.MapIndexToID(Row)
        If This.Rows.Has(Row)
            This.Rows.Delete(Row)
        If (BkColor = "") && (TxColor = "")
            Return True
        BkBGR := This.BGR(BkColor)
        TxBGR := This.BGR(TxColor)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        ; Colors := {B: (BkBGR != "") ? BkBGR : This.BkClr, T: (TxBGR != "") ? TxBGR : This.TxClr}
        This.Rows[Row] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
        Return True
    }
    ; ===================================================================================================================
    ; Cell()          Sets background and/or text color for the specified cell.
    ; Parameters:     Row         -  Row number
    ;                 Col         -  Column number
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> row's background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
    ;                                Default: Empty -> row's text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    Cell(Row, Col, BkColor := "", TxColor := "") {
        If !(This.HWND)
            Return False
        ;If (Row > This.RowCount) || (Col > This.ColCount)
        ;    Return False
        If This.IsStatic
            Row := This.MapIndexToID(Row)
        If This.Cells.Has(Row) && This.Cells[Row].Has(Col)
            This.Cells[Row].Delete(Col)
        If (BkColor = "") && (TxColor = "")
            Return True
        BkBGR := This.BGR(BkColor)
        TxBGR := This.BGR(TxColor)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        If !This.Cells.Has(Row)
            This.Cells[Row] := [], This.Cells[Row].Capacity := This.ColCount
        If (Col > This.Cells[Row].Length)
            This.Cells[Row].Length := Col
        This.Cells[Row][Col] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
        Return True
    }
    ; ===================================================================================================================
    ; NoSort()        Prevents/allows sorting by click on a header item for this ListView.
    ; Parameters:     Apply       -  True/False
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    NoSort(Apply := True) {
        If !(This.HWND)
            Return False
        This.LV.Opt((Apply ? "+" : "-") . "NoSort")
        Return True
    }
    ; ===================================================================================================================
    ; NoSizing()      Prevents/allows resizing of columns for this ListView.
    ; Parameters:     Apply       -  True/False
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    NoSizing(Apply := True) {
        If !(This.Header)
            Return False
        ControlSetStyle((Apply ? "+" : "-") . "0x0800", This.Header) ; HDS_NOSIZING = 0x0800
        Return True
    }
    ; ===================================================================================================================
    ; ShowColors()    Adds/removes a message handler for NM_CUSTOMDRAW notifications of this ListView.
    ; Parameters:     Apply       -  True/False
    ; Return Value:   Always True
    ; ===================================================================================================================
    ShowColors(Apply := True) {
        If (Apply) && !This.HasOwnProp("OnNotifyFunc") {
            This.OnNotifyFunc := ObjBindMethod(This, "NM_CUSTOMDRAW")
            This.LV.OnNotify(-12, This.OnNotifyFunc)
            WinRedraw(This.HWND)
        }
        Else If !(Apply) && This.HasOwnProp("OnNotifyFunc") {
            This.LV.OnNotify(-12, This.OnNotifyFunc, 0)
            This.OnNotifyFunc := ""
            This.DeleteProp("OnNotifyFunc")
            WinRedraw(This.HWND)
        }
        Return True
    }
    ; ===================================================================================================================
    ; Internally used/called Methods
    ; ===================================================================================================================
    NM_CUSTOMDRAW(LV, L) {
        ; Return values: 0x00 (CDRF_DODEFAULT), 0x20 (CDRF_NOTIFYITEMDRAW / CDRF_NOTIFYSUBITEMDRAW)
        Static SizeNMHDR := A_PtrSize * 3                  ; Size of NMHDR structure
        Static SizeNCD := SizeNMHDR + 16 + (A_PtrSize * 5) ; Size of NMCUSTOMDRAW structure
        Static OffItem := SizeNMHDR + 16 + (A_PtrSize * 2) ; Offset of dwItemSpec (NMCUSTOMDRAW)
        Static OffItemState := OffItem + A_PtrSize         ; Offset of uItemState  (NMCUSTOMDRAW)
        Static OffCT := SizeNCD                           ; Offset of clrText (NMLVCUSTOMDRAW)
        Static OffCB := OffCT + 4                          ; Offset of clrTextBk (NMLVCUSTOMDRAW)
        Static OffSubItem := OffCB + 4                     ; Offset of iSubItem (NMLVCUSTOMDRAW)
        Critical -1
        If !(This.HWND) || (NumGet(L, "UPtr") != This.HWND)
            Return
        ; ----------------------------------------------------------------------------------------------------------------
        DrawStage := NumGet(L + SizeNMHDR, "UInt"),
            Row := NumGet(L + OffItem, "UPtr") + 1,
            Col := NumGet(L + OffSubItem, "Int") + 1,
            Item := Row - 1
        If This.IsStatic
            Row := This.MapIndexToID(Row)
        ; CDDS_SUBITEMPREPAINT = 0x030001 --------------------------------------------------------------------------------
        If (DrawStage = 0x030001) {
            UseAltCol := (This.AltCols) && !(Col & 1),
                ColColors := (This.Cells.Has(Row) && This.Cells[Row].Has(Col)) ? This.Cells[Row][Col] : Map("B", "", "T", ""),
                ColB := (ColColors["B"] != "") ? ColColors["B"] : UseAltCol ? This.ACB : This.RowB,
                    ColT := (ColColors["T"] != "") ? ColColors["T"] : UseAltCol ? This.ACT : This.RowT,
                        NumPut("UInt", ColT, L + OffCT), NumPut("UInt", ColB, L + OffCB)
            Return (!This.AltCols && (Col > This.Cells[Row].Length)) ? 0x00 : 0x020
        }
        ; CDDS_ITEMPREPAINT = 0x010001 -----------------------------------------------------------------------------------
        If (DrawStage = 0x010001) {
            ; LVM_GETITEMSTATE = 0x102C, LVIS_SELECTED = 0x0002
            If (This.SelColors) && SendMessage(0x102C, Item, 0x0002, This.HWND) {
                ; Remove the CDIS_SELECTED (0x0001) and CDIS_FOCUS (0x0010) states from uItemState and set the colors.
                NumPut("UInt", NumGet(L + OffItemState, "UInt") & ~0x0011, L + OffItemState)
                If (This.SELB != "")
                    NumPut("UInt", This.SELB, L + OffCB)
                If (This.SELT != "")
                    NumPut("UInt", This.SELT, L + OffCT)
                Return 0x02 ; CDRF_NEWFONT
            }
            UseAltRow := This.AltRows && (Item & 1),
                RowColors := This.Rows.Has(Row) ? This.Rows[Row] : "",
                This.RowB := RowColors ? RowColors["B"] : UseAltRow ? This.ARB : This.BkClr,
                    This.RowT := RowColors ? RowColors["T"] : UseAltRow ? This.ART : This.TxClr
            If (This.AltCols || This.Cells.Has(Row))
                Return 0x20
            NumPut("UInt", This.RowT, L + OffCT), NumPut("UInt", This.RowB, L + OffCB)
            Return 0x00
        }
        ; CDDS_PREPAINT = 0x000001 ---------------------------------------------------------------------------------------
        Return (DrawStage = 0x000001) ? 0x20 : 0x00
    }
    ; -------------------------------------------------------------------------------------------------------------------
    MapIndexToID(Row) { ; provides the unique internal ID of the given row number
        Return SendMessage(0x10B4, Row - 1, 0, This.HWND) ; LVM_MAPINDEXTOID
    }
    ; -------------------------------------------------------------------------------------------------------------------
    BGR(Color, Default := "") { ; converts colors to BGR
        ; HTML Colors (BGR)
        Static HTML := { AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
            , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
            , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF }
        If IsInteger(Color)
            Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
        Return (HTML.HasOwnProp(Color) ? HTML.%Color% : Default)
    }
}
; Returns a file hash
HashFile(FilePath, HashType := 2) {
    Static PROV_RSA_AES := 24
    Static CRYPT_VERIFYCONTEXT := 0xF0000000
    Static BUFF_SIZE := 1024 * 1024 ; 1 MB
    Static HP_HASHVAL := 0x0002
    Static HP_HASHSIZE := 0x0004
    Switch HashType {
        Case 1: Hash_Alg := (CALG_MD2 := 32769)
        Case 2: Hash_Alg := (CALG_MD5 := 32771)
        Case 3: Hash_Alg := (CALG_SHA := 32772)
        Case 4: Hash_Alg := (CALG_SHA_256 := 32780)
        Case 5: Hash_Alg := (CALG_SHA_384 := 32781)
        Case 6: Hash_Alg := (CALG_SHA_512 := 32782)
        Default: throw ValueError('Invalid HashType', -1, HashType)
    }
    F := FileOpen(FilePath, "r")
    F.Pos := 0 ; Rewind in case of BOM.
    HCRYPTPROV() => {
        ptr: 0,
        __delete: this => this.ptr && DllCall("Advapi32\CryptReleaseContext", "Ptr", this, "UInt", 0)
    }
    If !DllCall("Advapi32\CryptAcquireContextW"
        , "Ptr*", hProv := HCRYPTPROV()
        , "Uint", 0
        , "Uint", 0
        , "Uint", PROV_RSA_AES
        , "UInt", CRYPT_VERIFYCONTEXT)
        Throw OSError()
    HCRYPTHASH() => {
        Ptr: 0,
        __Delete: This => This.Ptr && DllCall("Advapi32\CryptDestroyHash", "Ptr", This)
    }
    If !DllCall("Advapi32\CryptCreateHash"
        , "Ptr", hProv
        , "Uint", Hash_Alg
        , "Uint", 0
        , "Uint", 0
        , "Ptr*", hHash := HCRYPTHASH())
        Throw OSError()
    READ_BUF := Buffer(BUFF_SIZE, 0)
    While (cbCount := F.RawRead(READ_BUF, BUFF_SIZE)) {
        if !DllCall("Advapi32\CryptHashData"
            , "Ptr", hHash
            , "Ptr", READ_BUF
            , "Uint", cbCount
            , "Uint", 0)
            Throw OSError()
    }
    If !DllCall("Advapi32\CryptGetHashParam"
        , "Ptr", hHash
        , "Uint", HP_HASHSIZE
        , "Uint*", &HashLen := 0
        , "Uint*", &HashLenSize := 4
        , "UInt", 0)
        Throw OSError()
    bHash := Buffer(HashLen, 0)
    If !DllCall("Advapi32\CryptGetHashParam"
        , "Ptr", hHash
        , "Uint", HP_HASHVAL
        , "Ptr", bHash
        , "Uint*", &HashLen
        , "UInt", 0)
        Throw OSError()
    Loop HashLen
        HashVal .= Format('{:02x}', (NumGet(bHash, A_Index - 1, "UChar")) & 0xff)
    F.Close()
    Return HashVal
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
UseGDIP()