DefaultPB(Versions) {
    For Each, Version in Versions {
        CreateImageButton(Version, 0, [[0xFFFFFF,, 0x0000FF, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        Version.Redraw()
    }
}