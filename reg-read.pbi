#BIGBYTEINCREMENT = 4096
#SMALLBYTEINCREMENT = 1024
#RRF_RT_ANY = $ffff
#RRF_RT_DWORD = $18
#RRF_RT_QWORD = $48 ;Restrict type To 64-bit #RRF_RT_REG_BINARY | #RRF_RT_REG_DWORD.
#RRF_RT_REG_BINARY = $8
#RRF_RT_REG_DWORD = $10
#RRF_RT_REG_EXPAND_SZ = $4
#RRF_RT_REG_MULTI_SZ = $20
#RRF_RT_REG_NONE = $1
#RRF_RT_REG_QWORD = $40
#RRF_RT_REG_SZ = $2
#RRF_NOEXPAND = $10000000 ;Do Not automatically expand environment strings If the value is of type REG_EXPAND_SZ.
#RRF_ZEROONFAILURE = $20000000 ; RegGetValue - If pvData is not NULL, set the contents of the buffer to zeroes on failure

Prototype PRegGetValue(hkey, lpSubKey, lpValue, dwFlags, pdwType, pvData, pcbData)
Global RegGetValue.PRegGetValue

Lib_Advapi32 = OpenLibrary(#PB_Any,"Advapi32.dll")
If IsLibrary(Lib_Advapi32)
  CompilerIf #PB_Compiler_Unicode ; If compiled in unicode
    RegGetValue.PRegGetValue=GetFunction(Lib_Advapi32,"RegGetValueW")
  CompilerElse ; if not compiled in unicode
    RegGetValue.PRegGetValue=GetFunction(Lib_Advapi32,"RegGetValueA")
  CompilerEndIf
EndIf

Procedure.s ShowAPIError(CheckReturnValue) 
  Buffer.s = Space(4096) 
  NumberOfChars = FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM, #Null, CheckReturnValue, #Null, Buffer.s, Len(Buffer.s), #Null) 
  ProcedureReturn Left(Buffer.s, NumberOfChars-2) 
EndProcedure

Procedure.q TopHiveKey(HiveKeyConvert$)
  Protected HiveKeyx.q
  
  HiveKeya$=StringField(HiveKeyConvert$,1,"\")
  HiveKeyTop$=UCase(HiveKeya$)
  
  Select HiveKeyTop$
    Case "HKEY_CLASSES_ROOT"
      HiveKeyx = #HKEY_CLASSES_ROOT 
    Case "HKEY_CURRENT_USER"
      HiveKeyx = #HKEY_CURRENT_USER
    Case "HKEY_LOCAL_MACHINE"
      HiveKeyx = #HKEY_LOCAL_MACHINE
    Case "HKEY_USERS"
      HiveKeyx = #HKEY_USERS
    Case "HKEY_CURRENT_CONFIG"
      HiveKeyx = #HKEY_CURRENT_CONFIG
  EndSelect
  
  ProcedureReturn HiveKeyx
EndProcedure


Procedure.s KeyConvert(KeyToConvert$)
  GetBackSlash=FindString(KeyToConvert$,"\",1)
  KeyNameX$=Right(KeyToConvert$,(Len(KeyToConvert$)-GetBackSlash))
  If Left(KeyNameX$, 1) = "\" 
    KeyNameX$ = Right(KeyNameX$, Len(KeyNameX$) - 1) 
  EndIf
  ProcedureReturn KeyNameX$
EndProcedure

; gets value data for REG_BINARY, REG_QWORD, REG_SZ, REG_EXPAND_SZ, REG_BINARY, and REG_MULTI_SZ types
Procedure.s Reg_GetValue(Key.s, ValueName.s)
  ; using newer API RegGetValue:
  ; Older RegQueryValueEx API suffered from many issues and was possible security vunlerability. 
  ; The biggest issue was that it didn't adequately type check the data being returned.
  ; If the data for REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type, the string may not have been stored with the proper null-terminating characters and
  ; this could allow buffer overwrite
  ; In addition REG_MULTI_SZ strings should have two null-terminating characters, but the older RegQueryValueEx function only attempted to add one
  ; causing more code being needed to account for this.
  ; The newer API RegGetValue doesn't have these issues
  ; RegGetValue takes care of opening and closing the key thus no more RegOpenKeyEx needed
  ; RegGetValue automatically handles type REG_EXPAND_SZ.
  ; RegGetValue ensures proper null termination of registry string
  ; RegGetValue validates the length of the registry string was a multiple of 2.
  Protected pdwType.i, pcbData.i, pcbDatb.i, hKey.i, HiveKey.q, FuncRet.i, Type.i, pDWORD.i, REG_SBuf.s    
  
  pcbData = #SMALLBYTEINCREMENT; initial buffer size
  
  HiveKey = TopHiveKey(Key)
  KeyName$ = KeyConvert(Key)
  
  GetValue$ = ""
  *RegBinary = #Null
  *qResult = #Null
  REG_SBuf = ""
  REG_SBuf = Space(pcbData)
  
  FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_ANY, @Type, @REG_SBuf, @pcbData);; get type and buffer size
  ; regardless of actual buffer contents or type, this still gets the correct buffer size, so if we need more get it before selecting
  If FuncRet = #ERROR_MORE_DATA
    While FuncRet = #ERROR_MORE_DATA 
      pcbData = pcbData + #SMALLBYTEINCREMENT
      REG_SBuf = Space(pcbData)
      FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_ANY, #Null, @REG_SBuf, @pcbData) ; and uses the function again to test for enough buffer size
    Wend
  EndIf
  If FuncRet = #ERROR_FILE_NOT_FOUND
    ProcedureReturn ""
  EndIf
  
  If FuncRet = #ERROR_SUCCESS
    Select Type
      Case #REG_SZ
        FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_SZ, #Null, @REG_SBuf, @pcbData)
        GetValue$ = REG_SBuf
        REG_SBuf = ""
      Case #REG_MULTI_SZ
        FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_MULTI_SZ, #Null, @REG_SBuf, @pcbData)
        For MzCount.i = @REG_SBuf To @REG_SBuf + pcbData -2
          If PeekB(MzCount)=0
            GetValue$ + Chr(13) + "  "
          Else
            GetValue$ + Chr(PeekB(MzCount))
          EndIf
        Next
        REG_SBuf = ""
      Case #REG_EXPAND_SZ
        FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_EXPAND_SZ, #Null, @REG_SBuf, @pcbData)
        GetValue$ = REG_SBuf
        REG_SBuf = ""
      Case #REG_BINARY ; some REG_BINARY data can be really big and take a longgg time to read out - for example "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" - the "AppCompatCache" value can be really big and take a few minutes to get
        If pcbData > 0 ; special case - need to check binary data not zero-length or *RegBinary will crash with a zero buffer size
          *RegBinary=AllocateMemory(pcbData)
          FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_BINARY, #Null, *RegBinary, @pcbData)
          For BinCount.i = 0 To (pcbData-1)
            BinVar=PeekB(*RegBinary+BinCount)&$000000FF
            If BinVar<16
              GetValue$+"0"
            EndIf
            GetValue$ = GetValue$+ Hex(BinVar) + " "
          Next
          FreeMemory(*RegBinary)
          *RegBinary = #Null
        Else
          ProcedureReturn ""
        EndIf
      Case #REG_QWORD
        *qResult=AllocateMemory(pcbData)
        FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_QWORD, #Null, *qResult, @pcbData)
        GetValue$ = "0x" + Hex(PeekQ(*qResult)) + " (" + Str(PeekQ(*qResult)) + ")"
        FreeMemory(*qResult)
        *qResult = #Null
      Case #REG_DWORD
        FuncRet = RegGetValue(HiveKey, @KeyName$, @ValueName, #RRF_RT_REG_DWORD, #Null, @pDWORD, @pcbData)
        GetValue$ = Str(pDWORD)
    EndSelect
    ProcedureReturn GetValue$
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure
; IDE Options = PureBasic 5.50 (Windows - x64)
; Folding = -
; EnableXP