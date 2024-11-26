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