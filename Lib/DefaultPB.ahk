DefaultPB(Buttons, Style := [[0xFFFFFF,, 0x0000FF, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]) {
    For Each, Button in Buttons {
        CreateImageButton(Button, 0, Style*)
        Button.Redraw()
    }
}