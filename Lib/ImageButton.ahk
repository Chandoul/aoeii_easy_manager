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