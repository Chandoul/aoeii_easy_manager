; Checks the internet connection
GetConnectedState() {
    Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag := 0x40, "Int", 0)
}