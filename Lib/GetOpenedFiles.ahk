FolderLockCheck(Folder := '', &Locks := Map()) {
    If !Folder
        Return 0
    Try ProcessList := GetProcessListDllCall()
    Catch 
        Try ProcessList := GetProcessListCOM_Win32_Process()
            Catch
                Return 0
    For Process in ProcessList {
        For UsedResource in GetOpenedFiles(ProcessExist(Process)) {
            if InStr(UsedResource, Folder) {
                Locks[Process] := 1
            }
        }
    }
    Return 1
}

GatherProcessInfo(Process) {
    Return { Name: Process, Path: ProcessGetPath(Process) }
}

GetOpenedFiles(PID) {
    ; SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
    ; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_ex.htm
    ; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_table_entry_ex.htm
    static PROCESS_DUP_HANDLE := 0x0040
        , SystemExtendedHandleInformation := 0x40
        , DUPLICATE_SAME_ACCESS := 0x2
        , FILE_TYPE_DISK := 1
        , structSize := A_PtrSize * 3 + 16
    hProcess := DllCall("OpenProcess", "UInt", PROCESS_DUP_HANDLE
        , "UInt", 0
        , "UInt", PID)
    arr := map()
    res := size := 1
    while res != 0 {
        buff := Buffer(size, 0)
        res := DllCall("ntdll\NtQuerySystemInformation", "Int", SystemExtendedHandleInformation
            , "Ptr", buff.Ptr
            , "UInt", size
            , "UIntP", &size)
    }
    NumberOfHandles := NumGet(buff, "UPtr")
    VarSetStrCapacity(&filePath, 1026)
    Loop NumberOfHandles {
        ProcessId := NumGet(buff, A_PtrSize * 2 + structSize * (A_Index - 1) + A_PtrSize, "UInt")
        If (PID = ProcessId) {
            HandleValue := NumGet(buff, A_PtrSize * 2 + structSize * (A_Index - 1) + A_PtrSize * 2, "UPtr")
            lpTargetHandle := 0
            DllCall("DuplicateHandle", "Ptr", hProcess
                , "Ptr", HandleValue
                , "Ptr", DllCall("GetCurrentProcess")
                , "PtrP", &lpTargetHandle
                , "UInt", 0
                , "UInt", 0
                , "UInt", DUPLICATE_SAME_ACCESS)
            If DllCall("GetFileType", "Ptr", lpTargetHandle) = FILE_TYPE_DISK
                && DllCall("GetFinalPathNameByHandle", "Ptr", lpTargetHandle
                    , "Str", filePath
                    , "UInt", 512
                    , "UInt", 0)
                arr[RegExReplace(filePath, "^\\\\\?\\")] := ""
            DllCall("CloseHandle", "Ptr", lpTargetHandle)
        }
    }
    DllCall("CloseHandle", "Ptr", hProcess)
    str := []
    for k in arr
        str.Push(k)
    Return str
}

GetProcessListDllCall() {
    s := 4096  ; size of buffers and arrays (4 KB)

    ScriptPID := ProcessExist()  ; The PID of this running script.
    ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400):
    h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ScriptPID, "Ptr")
    ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32):
    DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", &t := 0)
    ; Retrieve the locally unique identifier of the debug privilege:
    DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", &luid := 0)
    ti := Buffer(16, 0)  ; structure of privileges
    NumPut("UInt", 1  ; one entry in the privileges array...
        , "Int64", luid
        , "UInt", 2  ; Enable this privilege: SE_PRIVILEGE_ENABLED = 2
        , ti)
    ; Update the privileges of this process with the new access token:
    r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
    DllCall("CloseHandle", "Ptr", t)  ; Close the access token handle to save memory.
    DllCall("CloseHandle", "Ptr", h)  ; Close the process handle to save memory.

    hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; Increase performance by preloading the library.
    a := Buffer(s)  ; An array that receives the list of process identifiers:
    c := 0  ; counter for process idendifiers
    l := ""
    DllCall("Psapi.dll\EnumProcesses", "Ptr", a, "UInt", s, "UIntP", &r)
    Loop r // 4  ; Parse array for identifiers as DWORDs (32 bits):
    {
        id := NumGet(a, A_Index * 4, "UInt")
        ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
        h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
        if !h
            continue
        n := Buffer(s, 0)  ; A buffer that receives the base name of the module:
        e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Ptr", n, "UInt", s // 2)
        if !e    ; Fall-back method for 64-bit processes when in 32-bit mode:
            e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Ptr", n, "UInt", s // 2)
        SplitPath StrGet(n), &n
        DllCall("CloseHandle", "Ptr", h)  ; Close the process handle to save memory.
        if (n && e)  ; If image is not null add to list:
            l .= (l = '' ? '' : '`n') n, c++
    }
    DllCall("FreeLibrary", "Ptr", hModule)  ; Unload the library to free memory.
    l := Sort(l)
    Return StrSplit(l, "`n")
}

GetProcessListCOM_Win32_Process() {
    l := ""
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        if SubStr(process.Name, -4) = '.exe'
            l .= (l = '' ? '' : '`n') process.Name
    l := Sort(l)
    Return StrSplit(l, "`n")
}